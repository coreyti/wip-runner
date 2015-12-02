module WIP
  module Runner
    module Commands
      class << self
        def locate(namespaces, name)
          return nil if name.nil? || name.match(/^-/)

          command = name.split('-').map(&:capitalize).join
          namespaces.each do |ns|
            return ns.const_get(command) if ns.const_defined?(command)
          end
          raise InvalidCommand, name
        end

        def within(namespace)
          namespace.constants
            .collect { |const|
              namespace.const_get(const)
            }
            .select { |command|
              command < Command # is a subclass of
            }
        end
      end
    end
  end
end

# NOTE: Commands are responsible for requiring sub-commands.
Dir[File.expand_path('../commands/*.rb', __FILE__)].each { |f| require(f) }
