require 'wip/runner/spec/helpers'

module WIP
  module Runner
    module Spec
      module Matchers ; end
    end
  end
end

Dir[File.expand_path('../matchers/*.rb', __FILE__)].each { |f| require(f) }
RSpec.configure do |config|
  config.include WIP::Runner::Spec::Matchers::Addons
end
