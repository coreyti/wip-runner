module WIP
  module Runner
    class CLI::Version < Command
      overview 'Prints version information'

      def execute(params, options)
        @io.say "#{WIP::Runner::CLI.signature} version #{WIP::Runner::CLI.namespace::VERSION}"
      end
    end
  end
end
