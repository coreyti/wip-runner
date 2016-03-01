module WIP::Runner::Spec
  module Matchers
    class WriteMatcher < RSpec::Matchers::BuiltIn::Output
      include RSpec::Matchers::BuiltIn
      include WIP::Runner::Spec::Helpers::StringHelpers

      def initialize(expected, stream)
        super(strip_heredoc(expected).strip)
        @stream = stream
      end

      def matches?(block)
        @block = block
        return false unless Proc === block

        @expected = @expected.strip
        @actual   = capture(block)

        values_match?(@expected, @actual)
      end

      def capture(block)
        capturer = if @stream == :stderr
          Capturer.new("stderr", $stderr)
        else
          Capturer.new("stdout", $stdout)
        end

        strip_heredoc(capturer.capture(block)).strip
      end

      def description
        "to receive the following content (#{@match} match):"
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

      class Capturer < CaptureStreamToTempfile
        def capture(block)
          if name == 'stdout'
            block.call
          else
            super
          end
        end
      end
    end
  end
end
