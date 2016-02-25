$LOAD_PATH.unshift File.expand_path('../..', __FILE__)

require 'rspec'
require 'support/helpers/string_helpers'
require 'support/matchers/write_matcher'

include Documentation::Support
Specdown::Config.expectations = :rspec
