require "synclenote"

require "yaml"
require "pathname"
require "logger"

require "thor"
require "evernote_oauth"
require "html/pipeline"

class Synclenote::Command < Thor
  attr_accessor :logger

  def initialize(*args, &block)
    super
    self.logger = Logger.new(STDOUT)
  end

  desc "init", "Create profile directory"
  def init
    if profile_path.exist?
      $stderr.puts(<<EOS)
Profile directory "#{profile_path}" is already exist.

Please check it and rename/remove it.
EOS
      exit(1)
    end
    profile_path.mkpath
    config_path.open("w") do |f|
      f.write(<<EOS)
# -*- mode: ruby -*-
# vi: set ft=ruby :

Synclenote.configure(1) do |config|
  # TODO: Replace your notes directory.
  config.local.directory = "~/notes"
  config.local.pattern = "**/*.{md,txt}"
  # You can use either whitelist_tags or blacklist_tags.
  # config.local.whitelist_tags = %w(smartphone tablet)
  # config.local.blacklist_tags = %w(noremote supersecret)

  config.remote.type = :evernote
  # You must fill your developer token.
  # See https://www.evernote.com/api/DeveloperToken.action
  config.remote.developer_token = "TODO: Write your developer token."
end
EOS
    end
    sync_statuses_path.mkpath
    last_sync_path.open("w") do |f|
      f.puts(YAML_HEADER)
      f.puts({last_sync_datetime: Time.at(0)}.to_yaml)
    end
    puts(<<EOS)
Creating new profile directory is succeeded.

Please check TODO in configuration file.
$ vi #{config_path}
EOS
  end

  desc "sync", "Sync all notes at once"
  def sync
    logger.debug("loading configuration file: %s" % config_path)
    load(config_path)
    c = Synclenote::Configuration.data
    token = c.remote.developer_token
    logger.debug("loaded configuration file: %s" % config_path)

    logger.debug("invoking client.")
    client = EvernoteOAuth::Client.new(token: token)
    logger.debug("invoked client.")

    logger.debug("invoking user_store.")
    user_store = client.user_store
    logger.debug("invoked user_store.")
    if !user_store.version_valid?
      raise "Invalid Evernote API version. Please update evernote_oauth.gem and synclenote.gem."
    end
    logger.debug("done EvernoteOAuth version check.")
    logger.debug("loading note_store.")
    note_store = client.note_store
    logger.debug("loaded note_store.")

    local_top_path = Pathname(c.local.directory)
    last_sync_status = YAML.load_file(last_sync_path)
    last_sync_datetime = last_sync_status[:last_sync_datetime]
    if Time.now - last_sync_datetime <= min_sync_interval
      allowed_sync_time = last_sync_datetime + min_sync_interval
      raise "too less interval sync after #{allowed_sync_time}."
    end

    processed = []
    Pathname.glob(local_top_path + c.local.pattern) do |note_path|
      relative_note_path = note_path.relative_path_from(local_top_path)
      note_sync_status_path = sync_statuses_path + relative_note_path
      processed << note_sync_status_path

      # create note
      if !note_sync_status_path.exist?
        create_remote_note(token, note_store, note_path, note_sync_status_path)
        next
      end

      # update note
      note_sync_status = YAML.load_file(note_sync_status_path)
      if note_sync_status[:last_sync_datetime] < note_path.mtime
        update_remote_note(token, note_store, note_path, note_sync_status_path,
                           note_sync_status[:guid])
        next
      end

      logger.debug("nothing: %s" % note_path)
    end

    # remove note
    removed = Pathname.glob(sync_statuses_path + c.local.pattern) - processed
    removed.each do |note_sync_status_path|
      remove_remote_note(token, note_store, note_sync_status_path)
    end
  end

  private

  YAML_HEADER = <<EOS.freeze
# -*- mode: yaml -*-
# vi: set ft=yaml :

EOS

  HEADER = <<EOS.freeze
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>
EOS

  FOOTER = <<EOS.freeze
</en-note>
EOS

  def profile_path
    return @profile_path ||= Pathname("~/.synclenote").expand_path
  end

  def config_path
    return @config_path ||= profile_path + "config"
  end

  def sync_statuses_path
    return @sync_statuses_path ||= profile_path + "sync_statuses"
  end

  def last_sync_path
    return @last_sync_path ||= profile_path + "last_sync"
  end

  def min_sync_interval
    # return 15 * 60 # 15 min for production
    return 4 # 4 sec for sandbox
  end

  def pipeline
    return @pipeline ||=
      ::HTML::Pipeline.new([
                             ::HTML::Pipeline::MarkdownFilter,
                             ::HTML::Pipeline::SanitizationFilter,
                             ::HTML::Pipeline::SyntaxHighlightFilter,
                             # ::HTML::Pipeline::PlainTextInputFilter,
                         ])
  end

  def create_note(note_path, options = {})
    title = nil
    tags = ["syncle"]
    body = nil
    note_path.open do |f|
      title = f.gets.chomp.sub(/\A#\s*/, "")
      if md = /\A(?<tags>(?:\[.*?\])+)(?:\s|\z)/.match(title)
        tags += md[:tags].scan(/\[(.*?)\]/).flatten
        title = md.post_match
      end
      body = f.read
    end
    html = pipeline.call(body, gfm: true)[:output].to_s
    content = HEADER +
      html.gsub(/ class=\".*?\"/, "").gsub(/<(br|hr).*?>/, "\\&</\\1>") +
      FOOTER
    o = options.merge(title: title, content: content, tagNames: tags)
    return Evernote::EDAM::Type::Note.new(o)
  end

  def target_note?(note)
    c = Synclenote::Configuration.data
    if c.local.whitelist_tags
      return note.tagNames.any? { |name|
        c.local.whitelist_tags.include?(name)
      }
    elsif c.local.blacklist_tags
      return !note.tagNames.any? { |name|
        c.local.blacklist_tags.include?(name)
      }
    end
    return true
  end

  def create_note_sync_status_file(path, note, sync_datetime)
    Tempfile.open("synclenote") do |tmp_file|
      tmp_file.puts(YAML_HEADER)
      tmp_file.puts({
                      last_sync_datetime: sync_datetime,
                      guid: note.guid,
                    }.to_yaml)
      tmp_file.close
      path.parent.mkpath
      FileUtils.mv(tmp_file.path, path)
    end
  end

  def create_remote_note(token, note_store, note_path, note_sync_status_path)
    c = Synclenote::Configuration.data
    new_note = create_note(note_path)
    if !target_note?(new_note)
      logger.info("skip creating: %s" % note_path)
      return
    end
    logger.debug("doing createNote: %s" % note_path)
    created_note = note_store.createNote(token, new_note)
    logger.debug("done createNote.")
    create_note_sync_status_file(note_sync_status_path, created_note,
                                 Time.now)
    logger.debug("created: %s" % note_sync_status_path)
  end

  def update_remote_note(token, note_store, note_path, note_sync_status_path,
                         guid)
    new_note = create_note(note_path, guid: guid)
    if !target_note?(new_note)
      logger.info("skip updating: %s" % note_path)
      remove_remote_note(token, note_store, note_sync_status_path)
      return
    end
    logger.debug("doing updateNote: %s %s" % [note_path, guid])
    updated_note = note_store.updateNote(token, new_note)
    logger.debug("done updateNote.")
    create_note_sync_status_file(note_sync_status_path, updated_note, Time.now)
    logger.debug("created: %s" % note_sync_status_path)
  end

  def remove_remote_note(token, note_store, note_sync_status_path)
    note_sync_status = YAML.load_file(note_sync_status_path)
    guid = note_sync_status[:guid]
    logger.debug("doing deleteNote: %s" % guid)
    note_store.deleteNote(token, guid)
    logger.debug("done deleteNote.")

    note_sync_status_path.delete
    logger.debug("removed: %s" % note_sync_status_path)
  end
end
