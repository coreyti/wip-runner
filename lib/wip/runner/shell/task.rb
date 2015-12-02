module WIP
  module Runner
    module Shell
      class Task
        attr_reader :configs, :shells, :children

        def initialize(command, &block)
          @command  = command
          @configs  = []
          @shells   = []
          @children = []
          @block    = block
        end

        def build(arguments, options)
          self.instance_exec(arguments, options, &@block) ; self
        end

        def config(term, options = {})
          @configs << [term.to_s, options] # Config.new(...)
        end

        def shell(handler, content, &block)
          shells << Handlers.locate(handler).new(content, &block)
        end

        def task(&block)
          children << Task.new(@command, &block)
        end

        protected

        def method_missing(method_name, *args, &block)
          if @command.respond_to?(method_name)
            @command.send(method_name, *args, &block)
          else
            # super
            @command.instance_eval {
              method_missing(method_name, *args, &block)
            }
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          @command.respond_to?(method_name) || super
        end
      end
    end
  end
end
