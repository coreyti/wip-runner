# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wip/runner/version'

Gem::Specification.new do |spec|
  spec.name          = "wip-runner"
  spec.version       = WIP::Runner::VERSION
  spec.authors       = ["Corey Innis"]
  spec.email         = ["corey@coolerator.net"]

  spec.summary       = %q{wip-runner is a generic CLI stand-alone and library.}
  spec.description   = %q{
    wip-runner...
    - A generic CLI (loads context-based commands)
    - A library for building such commands
  }
  spec.homepage      = "https://github.com/coreyti/wip-runner"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "highline"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
