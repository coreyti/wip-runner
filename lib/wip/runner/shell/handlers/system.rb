module WIP
  module Runner
    module Shell
      module Handlers
        class System < Base
          def execute(io, env, &block)
            IO.popen(env, executable, 'r') do |pipe|
              pipe.each(&block)
            end

            $?
          end
        end
      end
    end
  end
end
