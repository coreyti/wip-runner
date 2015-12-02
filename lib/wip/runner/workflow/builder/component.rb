module WIP
  module Runner
    module Workflow
      class Builder::Component
        def prologue(value = nil)
          @prologue = clean(value) unless value.nil?
          @prologue
        end

        def shell(*args)
          unless args.empty?
            shells << [args[0], clean(args[1])]
          end
        end

        def shells
          @shells ||= []
        end

        def method_missing(method_name, *args, &block)
          if @command.respond_to?(method_name)
            @command.send(method_name, *args, &block)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          @command.respond_to?(method_name) || super
        end

        private

        def clean(string)
          return if string.nil?

          indent = (string.scan(/^[ \t]*(?=\S)/).min || '').size
          string.gsub(/^[ \t]{#{indent}}/, '').strip
        end
      end
    end
  end
end
