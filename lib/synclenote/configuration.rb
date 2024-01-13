require "ostruct"

module Synclenote::Configuration
  # TODO: better code and multiple configuration support.
  @data = OpenStruct.new(local: OpenStruct.new(directory: "~/.synclenote",
                                               pattern: "**/*.{md,txt}",
                                               whitelist_tags: nil,
                                               blacklist_tags: nil),
                         remote: OpenStruct.new(type: nil))

  def self.run(version, &_block)
    fail "unknown API version: version=<#{version.inspect}>" if version != 1
    yield(@data)
  end

  def self.data
    return @data
  end
end
