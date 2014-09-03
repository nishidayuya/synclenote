require "synclenote"

require "ostruct"

module Synclenote::Configuration
  # TODO: better code and multiple configuration support.
  @data = OpenStruct.new(local: Struct.new(:directory, :pattern,
                                           :whitelist_tags,
                                           :blacklist_tags).new,
                         remote: Struct.new(:type, :developer_token).new)

  def self.run(version, &_block)
    fail "unknown API version: version=<#{version.inspect}>" if version != 1
    yield(@data)
  end

  def self.data
    return @data
  end
end
