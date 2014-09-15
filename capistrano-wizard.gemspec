# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/wizard/version'

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-wizard'
  spec.version       = Capistrano::Wizard::VERSION
  spec.authors       = ['Igor Kapkov']
  spec.email         = ['igasgeek@me.com']
  spec.summary       = %q{Capistrano 3 configurator}
  spec.description   = %q{Wizard for bootstrapping Capistrano configs}
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'LICENSE.txt', 'lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = ['cap-wizard']
  spec.require_path  = 'lib'
end
