module WIP
  module Runner
    class CLI::Documentation < Command
      overview 'Prints detailed command documentation'
      argument :argv, { overview: 'Command', multiple: true }

      def execute(arguments, options)
        @arguments = arguments

        command_parser.help
        @ui.err {
          @ui.newline
          @ui.say '---'
          @ui.newline
          @ui.say File.read(command_docs)
        }
      rescue InvalidCommand => e
        print_error(e)
      end

      private

      def command_class
        @command_class ||= @arguments.argv.map(&:capitalize).join('::')
      end

      def command_docs
        @command_docs ||= begin
          path = @arguments.argv.join('/')
          Dir["#{WIP::Runner::CLI.docs}/**/#{path}.md"].first
        end
      end

      def command_parser
        return CLI::Parser.new(@ui) if command_class.empty?
        Commands.locate(command_class).new(@ui).parser
      end
    end
  end
end
