module WIP
  module Runner
    class Command
      class Specification
        def initialize(command)
          @command = command
        end

        def read
          File.read(command_docs)
        end

        private

        def command_docs
          @command_docs ||= Dir["#{WIP::Runner::CLI.docs}/**/#{command_path}.md"].first
        end

        def command_path
          @command_path ||= begin
            [WIP::Runner::CLI.namespace.to_s.split('::').join('/').downcase, @command.signature.split(' ').join('/')].join('/')
          end
        end
      end
    end
  end
end
