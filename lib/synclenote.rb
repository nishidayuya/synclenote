# This module is a namespace for this gem.
module Synclenote
  DRY_RUN = false
  autoload :VERSION, "synclenote/varsion"

  autoload :Command, "synclenote/command"
  autoload :Configuration, "synclenote/configuration"

  def self.configure(version, &block)
    Configuration.run(version, &block)
  end
end
