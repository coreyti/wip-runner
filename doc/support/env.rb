$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'rspec'
require 'wip/runner/spec/matchers'
include WIP::Runner::Spec::Matchers::Addons

Specdown::Config.expectations = :rspec
