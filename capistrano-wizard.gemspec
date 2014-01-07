# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/wizard/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-wizard"
  spec.version       = Capistrano::Wizard::VERSION
  spec.authors       = ["Igor Kapkov"]
  spec.email         = ["igasgeek@me.com"]
  spec.summary       = %q{Capistrano 3 configurator}
  spec.description   = %q{Wizard for bootstrapping Capistrano configs}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
