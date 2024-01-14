# This module is a namespace for this gem.
module Synclenote
  DRY_RUN = false

  def self.configure(version, &block)
    Configuration.run(version, &block)
  end
end

(Pathname(__dir__).glob("**/*.rb") - [Pathname(__FILE__)]).map { |path|
  path.sub_ext("")
}.sort.each do |path|
  require(path.relative_path_from(__dir__))
end
