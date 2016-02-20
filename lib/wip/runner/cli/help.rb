module WIP
  module Runner
    class CLI::Help < Command
      overview 'Prints help messages'
      argument :command, { overview: 'Command name' }

      def execute(params, config)
        command_parser(params).help
      rescue InvalidCommand => e
        print_error(e)
      end

      def validate!(args)
        true
      end

      private

      def command_parser(params)
        command    = params.command
        return CLI::Parser.new(@ui) if command.nil?

        Commands.locate(command).new(@ui).parser
      end
    end
  end
end
