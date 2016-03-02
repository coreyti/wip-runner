module WIP
  module Runner
    class CLI::Documentation < Command
      overview 'Prints detailed command documentation'
      argument :argv, { overview: 'Command', multiple: true }

      def execute(arguments, config)
        docs = File.expand_path('../../../../../doc/wip/runner/cli', __FILE__)
        path = "#{File.join(docs, arguments.argv.join('/'))}.md"
        spec = File.read(path)
        command_parser(arguments.argv).help
        @ui.err {
          @ui.newline
          @ui.say '---'
          @ui.newline
          @ui.say spec
        }
      rescue InvalidCommand => e
        print_error(e)

        # @ui.out {
        #   @ui.say("#{WIP::Runner::CLI.signature} version #{WIP::Runner::CLI.namespace::VERSION}")
        # }
      end

      private

      def command_parser(argv)
        command = argv.map(&:capitalize).join('::')
        return CLI::Parser.new(@ui) if command.empty?

        Commands.locate(command).new(@ui).parser
      end
    end
  end
end
