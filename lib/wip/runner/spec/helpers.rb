module WIP
  module Runner
    module Spec
      module Helpers ; end
    end
  end
end

Dir[File.expand_path('../helpers/*.rb', __FILE__)].each { |f| require(f) }
RSpec.configure do |config|
  config.include WIP::Runner::Spec::Helpers::Matchers
  config.include WIP::Runner::Spec::Helpers::CommandHelpers
  config.include WIP::Runner::Spec::Helpers::UIHelpers
  config.include WIP::Runner::Spec::Helpers::StringHelpers
end
