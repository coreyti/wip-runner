module WIP
  module Runner
    class CLI::Help < Command
      overview 'Prints help messages'
      argument :command, { overview: 'Command' }

      def execute(arguments, config)
        command_parser(arguments).help
      rescue InvalidCommand => e
        print_error(e)
      end

      def validate!(args)
        true
      end

      private

      def command_parser(arguments)
        command = arguments.command
        return CLI::Parser.new(@ui) if command.nil?

        Commands.locate(command).new(@ui).parser
      end
    end
  end
end
