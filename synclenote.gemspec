# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'synclenote/version'

Gem::Specification.new do |spec|
  spec.name          = "synclenote"
  spec.version       = Synclenote::VERSION
  spec.authors       = ["Yuya.Nishida."]
  spec.email         = ["yuya@j96.org"]
  spec.summary       = File.readlines(File.join(__dir__, "README.md"))
    .reject { |l| /\A\s*\z|\A\#/ === l }.first.chomp
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/nishidayuya/" + spec.name
  spec.license       = "X11"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "evernote_oauth"
  spec.add_runtime_dependency "html-pipeline"
  spec.add_runtime_dependency "github-markdown", "= 0.6.7" # for MarkdownFilter
  spec.add_runtime_dependency "sanitize", "= 3.0.2" # for SanitizationFilter
  spec.add_runtime_dependency "github-linguist", "= 3.1.5" # for SyntaxHighlightFilter
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-bundler"
end
