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

      protected

      def namespaces
        [WIP::Runner::Commands, WIP::Runner::CLI]
      end

      private

      def command_parser(params)
        command = params.command
        return CLI::Parser.new(@io, namespaces) if command.nil?

        Commands.locate(namespaces, command).new(@io).parser
      end
    end
  end
end
