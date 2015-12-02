module WIP
  module Runner
    module Workflow
      class Builder::Task  < Builder::Component
        attr_reader :heading, :steps

        def initialize(command, heading, &block)
          @command = command
          @heading = heading
          @steps   = []
          instance_exec(&block) if block_given?
        end

        def step(name, &block)
          steps << Builder::Step.new(@command, name, &block)
        end
      end
    end
  end
end
