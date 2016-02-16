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

      def initialize(ui)
        @ui     = ui
        @parser = WIP::Runner::Parser.new(@ui, self.class)
      end

      def run(argv = [])
        begin
          parser.run(argv) do |command, arguments, options|
            if command.nil?
              if options.help
                parser.help
                return
              end

              validate!(arguments)
              execute(arguments, options)
            else
              # TODO: add a spec for the help path.
              command.match(/^-/) ? parser.help : delegate(command, argv)
            end
          end
        rescue OptionParser::InvalidOption => e
          raise InvalidOption, e.args.join(' ')
        end
      rescue InvalidArgument, InvalidArguments, InvalidCommand, InvalidOption, InvalidOptions => e
        print_error(e)
      end

      protected

      def execute(arguments, options)
        raise NotImplementedError
      end

      def validate!(arguments)
        unless parser.arguments.empty? || parser.config.no_validate
          missing = parser.arguments.keys.inject({}) do |memo, key|
            memo[key] = nil if arguments[key].nil?
            memo
          end
          raise InvalidArguments, missing unless missing.empty?
        end
      end

      private

      def delegate(command, argv)
        target = Commands.locate(command, self.class).new(@ui)
        target.run(argv)
      end

      def print_error(e)
        @ui.err {
          @ui.say(e.message)
          @ui.newline
        }
        parser.help
      end
    end
  end
end
