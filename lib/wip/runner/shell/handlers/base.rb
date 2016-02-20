require 'open3'

module WIP
  module Runner
    module Shell
      module Handlers
        class Base
          def initialize(content, &block)
            @content = clean(content)
            instance_exec(&block) if block_given?
          end

          def content(format = :text)
            case format
            when :markdown
              "```\n#{@content}\n```"
            else
              @content
            end
          end

          def execute(io, env, &block)
            raise NotImplementedError
          end

          def type
            @type ||= self.class.name.split('::').last
          end

          protected

          def executable
            @executable ||= begin
              content = @content.gsub(/"/, '\"').gsub(/\$/, "\\$")
              %Q{bash -c "#{content}"}
            end
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
end
