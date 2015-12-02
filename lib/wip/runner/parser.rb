module WIP
  module Runner
    class Parser
      attr_reader :config

      def initialize(io, command)
        @io      = io
        @command = command
        @config  = WIP::Runner::Options.new
      end

      def run(argv)
        unless commands.empty?
          command = argv.shift
          raise InvalidCommand, '(missing)' if command.nil?
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
        @io.say(options.help)
      end

      def options
        @options ||= OptionParser.new do |parser|
          @config.help        = false
          @config.no_validate = false

          parser.banner = "Usage: wip-runner #{heading}"

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

          pairs.each do |name, details|
            padding = ' ' * (parser.summary_width - name.length + 1)
            parser.separator [parser.summary_indent, name, padding, details[:overview]].join('')
          end
        end
      end
    end
  end
end
