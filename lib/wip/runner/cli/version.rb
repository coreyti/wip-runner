module WIP
  module Runner
    class CLI::Version < Command
      overview 'Prints version information'

      def execute(*)
        @ui.out {
          @ui.say("#{WIP::Runner::CLI.signature} version #{WIP::Runner::CLI.namespace::VERSION}")
        }
      end
    end
  end
end
