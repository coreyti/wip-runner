require 'ostruct'

module WIP
  module Runner
    class Options < OpenStruct
      def to_hash
        self.to_h
      end

      def each(&block)
        self.to_h.each(&block)
      end

      def keys
        self.to_h.keys
      end

      def values
        self.to_h.values
      end

      def merge(other)
        Options.new(self.to_h.merge(other.to_h))
      end
    end
  end
end
