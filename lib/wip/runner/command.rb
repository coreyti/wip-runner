module WIP
  module Runner
    class Command
      class << self
        def signature
          @signature ||= begin
            ns    = Commands.name
            parts = self.name
              .sub(/^.*(CLI|Commands)::/, '')
              .split('::')
            parts.map { |part| part.gsub(/([A-Z])/, "-\\1").sub(/^-/, '') }
              .join(' ')
              .downcase
          end
        end

        def overview(value = nil)
          @overview = value unless value.nil?
          @overview
        end

        def commands
          @commands ||= Commands.within(self)
        end

        def argument(name, definition)
          arguments[name] = Options.new(definition)
        end

        def arguments(value = nil)
          @arguments ||= {}
        end

        # TODO: test multi-options
        def options(&block)
          @options ||= []
          @options << block if block_given?
          @options
        end

        def workflow(&block)
          Workflow.define(&block)
        end
      end

      attr_reader :parser # TODO(?)... :arguments, :options

      def initialize(io)
        @io     = io
        @parser = WIP::Runner::Parser.new(@io, self.class)
      end

      def run(argv = [])
        parser.run(argv) do |command, arguments, options|
          if command.nil?
            if options.help
              parser.help
              return
            end

            validate!(arguments)
            execute(arguments, options)
          else
            delegate(command, argv)
          end
        end
      rescue OptionParser::InvalidOption, InvalidArguments, InvalidCommand => e
        print_error(e)
      end

      protected

      def execute(arguments, options)
        raise NotImplementedError
      end

      def validate!(arguments)
        unless parser.arguments.empty? || parser.config.no_validate
          if parser.arguments.keys.any? { |key| arguments[key].nil? }
            lines = []
            arguments.each_pair do |key, value|
              lines << "  - #{key} ... (missing)" if value.nil?
            end
            raise InvalidArguments, %Q{\n#{lines.join("\n")}}
          end
        end
      end

      private

      def delegate(command, argv)
        target = Commands.locate(command, self.class).new(@io)
        target.run(argv)
      end

      def print_error(e)
        @io.say(e.message.capitalize)
        @io.newline
        parser.help
      end
    end
  end
end
