module WIP::Runner::Renderer
  class Helper
    def self.for(context, mod)
      self.instance_eval { include mod }
      self.new(context)
    end

    def initialize(context)
      @context = context
    end

    protected

    def method_missing(method_name, *args, &block)
      if @context.respond_to?(method_name)
        @context.send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @context.respond_to?(method_name) || super
    end
  end
end
