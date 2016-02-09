module WIP
  module Runner::Spec
    module Helpers::CommandHelpers
      def define_command(&block)
        klass = Class.new(WIP::Runner::Command)
        klass.instance_exec do
          def name
            'Command'
          end
        end
        klass.class_exec(&block)
        klass
      end

      def example_command(implementation)
        ExampleCommands.const_get(implementation).new(io)
      end

      module ExampleCommands
        class Simple < WIP::Runner::Command
          def execute(args, options)
            @executed = true
          end

          def executed?
            !! @executed
          end
        end

        class WithOptions < Simple
          options do |parser, config|
            config.flagged = false

            parser.on('-f', '--flag', 'Option 1') do
              config.flagged = true
            end
          end

          attr_reader :flagged

          def execute(args, options)
            super
            @flagged = options.flagged
          end
        end

        class WithArguments < Simple
          argument :arg_01, { overview: 'Argument 1' }
          argument :arg_02, { overview: 'Argument 2' }
        end

        class WithNested < Simple ; end

        class WithNested::Nested < Simple
          overview 'A nested command'

          def execute(args, options)
            super
            @io.say 'running nested command...'
          end
        end

        # class WithTasks < Simple
        #   def execute(args, options)
        #
        #   end
        #
        #   def task
        #     Shell::Task.new(self) do |arguments, options|
        #       config :VARIABLE
        #       shell :script, %{
        #         echo $VARIABLE
        #       }
        #     end
        #   end
        # end
      end
    end
  end
end
