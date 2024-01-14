# coding: utf-8

require "pathname"

top_path = Pathname(__dir__).expand_path
lib_path = top_path / "lib"
$LOAD_PATH.unshift(lib_path)
require 'synclenote/version'

Gem::Specification.new do |spec|
  spec.name          = "synclenote"
  spec.version       = Synclenote::VERSION
  spec.authors       = ["Yuya.Nishida."]
  spec.email         = ["yuya@j96.org"]
  spec.summary = (top_path / "README.md").each_line(chomp: true).lazy.
                   grep_v(/\A\s*\z|\A\#/).first
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nishidayuya/" + spec.name
  spec.license       = "X11"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "base64" # suppress warnings
  spec.add_runtime_dependency "evernote_oauth"
  spec.add_runtime_dependency "redcarpet"
  spec.add_runtime_dependency "thor"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "debug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "test-unit"
end
