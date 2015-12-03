require 'erb'

module WIP
  module Runner
    module Renderers
      module ERB
        def self.included(base)
          base.extend(ClassMethods)
        end

        def render(template, context)
          if (file = File.join("#{self.class.templates}/#{template}.erb")) && File.exist?(file)
            template = File.read(file)
          end
          ::ERB.new(clean(template)).result(context)
        end

        def clean(string)
          return if string.nil?

          indent = (string.scan(/^[ \t]*(?=\S)/).min || '').size
          string.gsub(/^[ \t]{#{indent}}/, '').strip
        end

        module ClassMethods
          def templates(value = nil)
            @templates = value unless value.nil?
            @templates
          end
        end
      end
    end
  end
end
