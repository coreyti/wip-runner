module WIP
  module Runner::Spec
    module Helpers::StringHelpers
      def strip_heredoc(string)
        indent = string.scan(/^[ \t]*(?=\S)/).min.size || 0
        string.gsub(/^[ \t]{#{indent}}/, '')
      end
    end
  end
end
