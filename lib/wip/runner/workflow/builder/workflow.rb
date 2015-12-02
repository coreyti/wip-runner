module WIP
  module Runner
    module Workflow
      class Builder::Workflow  < Builder::Component
        def initialize(command)
          @command = command
          @configs = []
          @guards  = []
          @tasks   = []
        end

        # ---

        def config(key, options = {})
          @configs << [key.to_s, options]
        end

        def guard(description, check, expectation = nil)
          @guards << [description, check, expectation]
        end

        def task(heading, &block)
          @tasks << Builder::Task.new(@command, heading, &block)
        end

        # ---

        def heading
          [@command.class.name.split('::').last, 'Workflow'].join(' ')
        end

        def overview
          clean(@command.class.overview)
        end

        def configs
          @configs
        end

        def guards
          @guards
        end

        def tasks
          @tasks
        end
      end
    end
  end
end
