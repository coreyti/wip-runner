module WIP
  module Runner
    module Workflow
      class Builder
        def initialize(command, &block)
          @command = command
          @block   = block
        end

        def build(arguments, options)
          workflow = Workflow.new(@command)
          workflow.instance_exec(arguments, options, &@block)
          workflow
        end
      end
    end
  end
end
