module WIP
  module Runner
    class CLI
      class << self
        def allow(path, search)
          search.each do |dir|
            extension = File.join(dir, path)
            if File.exist?("#{extension}.rb")
              $:.push(File.join(extension, 'lib'))
              require extension
              assets(File.join(extension, 'assets'))
            end
          end
        end

        def signature=(value)
          @signature = value
        end

        def signature
          @signature || 'wip-runner'
        end

        def namespace=(value)
          @namespace = value
        end

        def namespace
          @namespace || WIP::Runner
        end

        def assets(*paths)
          @assets ||= []
          unless paths.empty?
            @assets = (@assets + paths.flatten).uniq
          end
          @assets
        end
      end

      def initialize(ui = UI.new)
        @ui     = ui
        @parser = Parser.new(ui)
        trap('INT')  { quit }
        trap('TERM') { quit }
      end

      def quit
        exit
      end

      def run(argv = [])
        args      = argv.dup
        recipient = (command(args) || @parser)
        recipient.run(args)
      rescue InvalidCommand => e
        @ui.err {
          @ui.say(e.message)
          @ui.newline
        }
        @parser.help
      end

      private

      def command(args)
        handler = Commands.locate(args.shift)
        handler.nil? ? nil : handler.new(@ui)
      end

      class Parser
        def initialize(ui)
          @ui = ui
        end

        def run(args)
          return help if args.empty?
          options.parse!(args)
        end

        def help
          @ui.out {
            @ui.say(options.help)
          }
        end

        private

        def options
          @options ||= OptionParser.new do |parser|
            parser.banner = "Usage: #{WIP::Runner::CLI.signature} <command> [options]"

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
              @ui.err {
                @ui.say(parser)
              }
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

        def namespace
          WIP::Runner::CLI.namespace
        end

        def implicit
          @implicit ||= Commands.within(WIP::Runner::Commands.implicit)
        end

        def explicit
          @explicit ||= Commands.within(WIP::Runner::Commands.explicit)
        end
      end
    end
  end
end
