module Documentation
  module Support
    def write(expected, options = {})
      WriteMatcher.new(expected, options[:to] || :stdout)
    end

    class WriteMatcher < RSpec::Matchers::BuiltIn::Output
      include RSpec::Matchers::BuiltIn
      include Documentation::Support::Helpers

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
          CaptureStreamToTempfile.new("stderr", $stderr)
        else
          CaptureStreamToTempfile.new("stdout", $stdout)
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
    end
  end
end
