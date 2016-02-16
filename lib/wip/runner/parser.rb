require 'wip/runner/parser/option_parser'

# TODO:
# - be sure repeated flags are supported: `command --flag A --flag B`
# - support `arguments` as an Array-like object of all non-flag arguments
# - support (?) "application options" (preceding args/commands) and "command options"
#   - options.foo                     ... get any option by name
#   - options.for_application('foo')  ... get an application option
#   - options.for_command('foo')      ... get a command option
module WIP
  module Runner
    class Parser
      attr_reader :config

      def initialize(ui, command)
        @ui      = ui
        @command = command
        @config  = WIP::Runner::Options.new
      end

      def run(argv)
        unless commands.empty?
          command = argv.shift
          raise InvalidCommand if command.nil?
          yield(command, nil, nil)
        else
          remaining = options.parse!(argv)

          @args = WIP::Runner::Options.new.tap do |opts|
            arguments.keys.each_with_index do |key, index|
              opts[key] = remaining[index]
            end
          end

          yield(nil, @args, @config)
        end
      end

      def help
        @ui.err {
          @ui.say(options.help)
        }
      end

      def options
        @options ||= OptionParser.new do |parser|
          @config.help        = false
          @config.no_validate = false

          parser.banner = "Usage: #{WIP::Runner::CLI.signature} #{heading}"

          section(parser, 'Commands:', commands)
          section(parser, 'Arguments:', arguments)

          parser.separator ''
          parser.separator 'Options:'

          @command.options.each do |block|
            block.call(parser, @config)
          end

          parser.on_tail '-h', '--help', 'Prints help messages' do
            @config.help = true
          end
        end
      end

      def arguments
        @command.arguments
      end

      private

      def commands
        {}.tap do |result|
          @command.commands.each do |command|
            result[command.signature.split(' ').last.intern] = { overview: command.overview }
          end
        end
      end

      def heading
        sections = [].tap do |result|
          result << '<command>'   unless commands.empty?
          result << '<arguments>' unless commands.empty? && arguments.empty?
        end

        [@command.signature, sections, '[options]'].flatten.join(' ')
      end

      def section(parser, heading, pairs)
        unless pairs.empty?
          parser.separator ''
          parser.separator heading

          pairs.each do |name, definition|
            padding   = ' ' * (parser.summary_width - name.length + 1)
            overview  = definition[:overview]
            parser.separator [parser.summary_indent, name, padding, overview].join('')
          end
        end
      end
    end
  end
end
