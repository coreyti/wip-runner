module WIP
  module Runner
    class CLI::Documentation < Command
      overview 'Prints detailed command documentation'
      argument :argv, { overview: 'Command', multiple: true }

      def execute(arguments, config)
        raise command_parser(arguments).inspect
      rescue InvalidCommand => e
        print_error(e)

        # @ui.out {
        #   @ui.say("#{WIP::Runner::CLI.signature} version #{WIP::Runner::CLI.namespace::VERSION}")
        # }
      end

      private

      def command_parser(arguments)
        return CLI::Parser.new(@ui) if command.empty?
        command = arguments.argv.map(&:capitalize).join('::')

        Commands.locate(command).new(@ui).parser
      end
    end
  end
end
