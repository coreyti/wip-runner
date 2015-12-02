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
      def message
        prefix = self.class.name.split('::').last
          .gsub(/([A-Z])/, " \\1")
          .strip
          .capitalize
        "#{prefix}: #{super}".sub(/\s\n/, "\n")
      end
    end
    class InvalidArguments < Error; end
    class InvalidCommand   < Error; end
  end
end
