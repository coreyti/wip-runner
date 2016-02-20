module WIP
  module Runner
    module Shell
      class Task
        attr_reader :heading, :configs, :shells, :steps

        def initialize(command, *args, &block)
          @command = command
          @configs = []
          @shells  = []
          @steps   = []
          @heading = args.first unless args.empty?
          @block   = block
        end

        def build(arguments, options)
          self.instance_exec(arguments, options, &@block) ; self
        end

        def heading?
          !! @heading
        end

        def config(term, options = {}, &block)
          @configs << [term.to_s, options, block] # Config.new(...)
        end

        def shell(handler, content, &block)
          shells << Handlers.locate(handler).new(content, &block)
        end

        def task(*args, &block)
          steps << Task.new(@command, *args, &block)
        end

        protected

        def method_missing(method_name, *args, &block)
          if @command.respond_to?(method_name)
            @command.send(method_name, *args, &block)
          else
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
