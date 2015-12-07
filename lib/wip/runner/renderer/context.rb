module WIP::Runner::Renderer
  class Context
    class << self
      def for(context = {})
        self.new(context).send(:__binding__)
      end
    end

    def initialize(context)
      context.each do |key, value|
        if value.is_a?(Module)
          value = Helper.for(self, value)
        end
        self.class.send(:define_method, key.intern, Proc.new { value })
      end
    end

    private

    def __binding__
      binding
    end
  end
end
