module WIP
  module Runner
    class CLI::Version < Command
      overview 'Prints version information'

      def execute(params, options)
        @io.say "wip-runner version #{WIP::Runner::VERSION}"
      end
    end
  end
end
