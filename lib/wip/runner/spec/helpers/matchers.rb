module WIP
  module Runner::Spec
    module Helpers::Matchers
      def show(expected, options = {})
        stream = options[:to]    || :out  # :to    => [:out | :err]
        match  = options[:match] || :full # :match => [:full | :partial]
        ShowMatcher.new(self, strip_heredoc(expected).strip, stream, match)
      end

      class ShowMatcher < RSpec::Matchers::BuiltIn::Output
        def initialize(example, expected, stream, match)
          super(expected)
          @example = example
          @stream  = stream
          @match   = match
        end

        def matches?(block)
          @block = block
          return false unless Proc === block

          @expected = @expected.strip
          @actual = Capturer.capture(@example.ui, @stream, block)
          @actual = @example.strip_heredoc(@actual).strip

          if @match == :partial
            values_match?(/#{Regexp.escape(@expected)}/, @actual)
          else
            values_match?(@expected, @actual)
          end
        end

        def description
          "STD#{@stream.upcase} to receive the following content (#{@match} match):"
        end

        def failure_message
          [
            "expected #{description}",
            "Expected:",
            "#{@expected}\n",
            "Actual:",
            "#{@actual}\n\n"
          ].join("\n\n")
        end

        # @private
        module Capturer
          def self.capture(ui, stream, block)
            captured = StringIO.new
            highline = ui.send(stream)
            original = highline.instance_variable_get(:'@output')
            highline.instance_variable_set(:'@output', captured)

            block.call
            captured.string
          ensure
            highline.instance_variable_set(:'@output', original)
          end
        end
      end
    end
  end
end
