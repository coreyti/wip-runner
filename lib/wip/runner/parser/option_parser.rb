module WIP
  module Runner
    class Parser
      class OptionParser < ::OptionParser
        def list(items, mode = :rows, option = nil, pad = true)
          if (mode == :rows)
            items   = items.map { |item| "#{option} #{item}" } if option
            items.join("\n#{pad ? padding : nil}")
          else
            HighLine.new.list(items, mode, option)
          end
        end

        def wrap(text, mode = :description, line_width = 80)
          indented = false

          if mode == :description
            line_width -= indentation
            indented = true
          end

          wrapped = text.split("\n").collect! do |line|
            line.length > line_width ? line.gsub(/(.{1,#{line_width}})(\s+|$)/, "\\1\n").strip : line
          end * "\n"

          indented ? wrapped.split("\n").join("\n#{padding}") : wrapped
        end

        private

        def indentation
          @indentation ||= summary_indent.length + summary_width + 1
        end

        def padding
          @padding ||= ' ' * indentation
        end
      end
    end
  end
end
