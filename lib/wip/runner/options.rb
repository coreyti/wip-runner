require 'ostruct'

module WIP
  module Runner
    class Options < OpenStruct
      def each(&block)
        self.to_h.each(&block)
      end

      def keys
        self.to_h.keys
      end

      def values
        self.to_h.values
      end
    end
  end
end
