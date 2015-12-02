module Support
  def show(expected, options = {})
    output = options[:output] || :highline
    match  = options[:match]  || :full # :match => [:full | :partial]
    ShowMatcher.new(self, strip_heredoc(expected).strip, output, match).send(:"to_#{output}")
  end

  class ShowMatcher < RSpec::Matchers::BuiltIn::Output
    def initialize(example, expected, output, match)
      super(expected)
      @example = example
      @output  = output
      @match   = match
    end

    def matches?(block)
      @block = block
      return false unless Proc === block

      @expected = @expected.strip

      if @output == :highline
        @actual = @stream_capturer.capture(@example.io, block)
        @actual = @example.strip_heredoc(@actual).strip
      else
        @actual = @stream_capturer.capture(block).strip
      end

      if @match == :partial
        values_match?(/#{Regexp.escape(@expected)}/, @actual)
      else
        values_match?(@expected, @actual)
      end
    end

    def description
      "#{@stream_capturer.name} to receive the following content (#{@match} match):"
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

    def to_highline
      @stream_capturer = CaptureHighline
      self
    end

    # @private
    module CaptureHighline
      def self.name
        'highline'
      end

      def self.capture(io, block)
        captured_stream = StringIO.new

        original_stream = io.instance_variable_get(:'@output')
        io.instance_variable_set(:'@output', captured_stream)

        block.call

        captured_stream.string
      ensure
        io.instance_variable_set(:'@output', captured_stream)
      end
    end
  end
end
