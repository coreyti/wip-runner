module WIP
  module Runner
    module Workflow
      class Builder::Step  < Builder::Component
        attr_reader :heading

        def initialize(command, heading, &block)
          @command = command
          @heading = heading
          instance_exec(&block) if block_given?
        end
      end
    end
  end
end
