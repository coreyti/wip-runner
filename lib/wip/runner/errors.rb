module WIP
  # TODO: consider...
  #
  # - OptionParser::ParseError:: errors on parsing
  #   - OptionParser::AmbiguousArgument
  #   - OptionParser::InvalidArgument
  #   - OptionParser::MissingArgument
  #   - OptionParser::NeedlessArgument
  #   - OptionParser::AmbiguousOption
  #   - OptionParser::InvalidOption
   module Runner
    class Error < StandardError
      def initialize(message = nil)
        super
        @message = message
      end

      def message
        "#{prefix.capitalize}: #{format(super)}".sub(/\s\n/, "\n")
      end

      private

      def format(original)
        if @message.is_a?(Array)
          values = @message.map(&:to_s)
          width  = values.sort { |a, b| b.size <=> a.size }[0].size
          lines  = []
          values.each do |value|
            lines << sprintf("    - %-#{width}s", value)
          end
          "\n#{lines.join("\n")}"
        elsif @message.respond_to?(:each) # e.g., Hash, WIP::Runner::Options
          keys  = @message.keys.map(&:to_s)
          width = keys.sort { |a, b| b.size <=> a.size }[0].size
          lines = []
          @message.each do |key, value|
            lines << [
              sprintf("    - %-#{width}s", key.to_s),
              format_value(value)
            ].join(' ... ')
          end
          "\n#{lines.join("\n")}"
        else
          format_value(@message)
        end
      end

      def format_value(value)
        case value
        when nil
          '(missing)'
        else
          value
        end
      end

      def prefix
        self.class.name.split('::').last.gsub(/([A-Z])/, " \\1")
          .strip
          .capitalize
      end
    end

    class InvalidArgument  < Error ; end
    class InvalidArguments < Error ; end
    class InvalidCommand   < Error ; end
    class InvalidOption    < Error ; end
    class InvalidOptions   < Error ; end
  end
end
