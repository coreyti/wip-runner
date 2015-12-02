require 'wip/runner/shell/handlers/base'
require 'wip/runner/shell/handlers/script'
require 'wip/runner/shell/handlers/system'

module WIP
  module Runner
    module Shell
      module Handlers
        class << self
          def locate(key)
            const_get(key.to_s.capitalize)
          end
        end
      end
    end
  end
end
