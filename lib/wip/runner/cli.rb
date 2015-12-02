require 'highline'

module WIP
  module Runner
    class CLI
      def initialize(io = HighLine.new)
        @io     = io
        @parser = Parser.new(io, namespaces)

        trap('INT')  { quit }
        trap('TERM') { quit }
      end

      def quit
        exit
      end

      def run(args = [])
        recipient = (command(args) || @parser)
        recipient.run(args)
      rescue InvalidCommand => e
        @io.say(e.message)
        @io.newline
        @parser.help
      end

      protected

      def namespaces
        [WIP::Runner::Commands, WIP::Runner::CLI]
      end

      private

      def command(args)
        handler = Commands.locate(namespaces, args.shift)
        handler.nil? ? nil : handler.new(@io)
      end

      class Parser
        def initialize(io, namespaces)
          @io         = io
          @namespaces = namespaces
        end

        def run(args)
          return help if args.empty?
          options.parse!(args)
        end

        def help
          @io.say(options.help)
        end

        private

        def options
          @options ||= OptionParser.new do |parser|
            parser.banner = 'Usage: wip-runner <command> [options]'

            parser.separator ''
            parser.separator 'Commands:'

            explicit.each do |command|
              display(parser, command)
            end
            if explicit.length > 0 && implicit.length > 0
              parser.separator [parser.summary_indent, '---'].join
            end
            implicit.each do |command|
              display(parser, command)
            end

            parser.separator ''
            parser.separator 'Options:'

            parser.on_tail '-h', '--help', 'Prints help messages' do
              @io.say(parser)
            end
          end
        end

        def display(parser, command)
          signature = command.signature
          overview  = command.overview
          padding   = ' ' * (parser.summary_width - signature.length + 1)
          parser.separator [parser.summary_indent, signature, padding, overview].join
        end

        # ---

        def implicit
          @implicit ||= if @namespaces.length > 1
            Commands.within(@namespaces[-1])
          else
            []
          end
        end

        def explicit
          @explicit ||= if @namespaces.length > 1
            @namespaces[0..-2].collect { |ns| Commands.within(ns) }.flatten
          else
            Commands.within(@namespaces[0])
          end
        end
      end
    end
  end
end
