module Synclenote::NoteBuilder
  DEFAULT_TAGS = %w[syncle]

  TITLE_IF_EMPTY = "no title"

  class << self
    def call(raw_note, guid: nil)
      lines = raw_note.each_line.lazy
      title, tags_in_raw_note, body_markdown = *parse_lines(lines)
      title = TITLE_IF_EMPTY if /\A\s*\z/ === title
      tags = (DEFAULT_TAGS + tags_in_raw_note).uniq
      enml = Synclenote::MarkdownToEnmlBuilder.(body_markdown)

      options = {
        title:,
        content: enml,
        tagNames: tags,
      }
      options[:guid] = guid if guid
      return Evernote::EDAM::Type::Note.new(options)
    end

    private

    def parse_lines(lines)
      tags = []
      title = lines.first.chomp.sub(/\A#\s*/, "")
      lines = lines.drop(1)
      md = /\A(?<tags>(?:\[.*?\])+)(?:\s|\z)/.match(title)
      if md
        tags = md[:tags].scan(/\[(.*?)\]/).flatten
        title = md.post_match
      end

      lines = lines.drop_while { |l| /\A\s*\z/ === l }
      body_markdown = lines.to_a.join

      return [title, tags, body_markdown]
    end
  end
end
