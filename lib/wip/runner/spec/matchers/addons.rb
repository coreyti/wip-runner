module WIP::Runner::Spec
  module Matchers
    module Addons
      def write(expected, options = {})
        WriteMatcher.new(expected, options[:to] || :stdout)
      end
    end
  end
end
