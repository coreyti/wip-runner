module WIP
  module Runner
    module Shell
      module Handlers
        class System < Base
          def description
            # @description ||= "```\n#{@content}\n```"
            @description ||= @content
          end

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
