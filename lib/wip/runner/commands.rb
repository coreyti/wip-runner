module WIP
  module Runner
    module Commands
      class << self
        def locate(name, namespace = nil)
          return nil if name.nil? || name.match(/^-/)

          command    = name.split('-').map(&:capitalize).join
          namespaces = namespace ? [namespace] : [explicit, implicit]
          namespaces.each do |ns|
            return ns.const_get(command) if ns && ns.const_defined?(command)
          end
          raise InvalidCommand, name
        rescue
          raise InvalidCommand, name
        end

        def within(namespace)
          return [] if namespace.nil?

          namespace.constants
            .collect { |const|
              namespace.const_get(const)
            }
            .select { |command|
              command < Command # is a subclass of
            }
        end

        def implicit
          WIP::Runner::CLI
        end

        def explicit
          @explicit ||= begin
            namespace.const_get(:Commands) if namespace.const_defined?(:Commands)
          end
        end

        def namespace
          WIP::Runner::CLI.namespace
        end
      end
    end
  end
end

# NOTE: Commands are responsible for requiring sub-commands.
Dir[File.expand_path('../commands/*.rb', __FILE__)].each { |f| require(f) }
