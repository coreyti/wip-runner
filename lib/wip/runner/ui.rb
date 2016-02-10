require 'highline'

module WIP
  module Runner
    class UI
      def initialize(input = $stdin, out = $stdout, err = $stderr)
        @out = HighLine.new(input, out, nil, nil, 2, 0)
        @err = HighLine.new(input, err, nil, nil, 2, 0)
      end

      protected

      def method_missing(method_name, *args, &block)
        stream = args.first

        if [:out, :err].include?(stream)
          send(stream).send(method_name, *args[1..-1], &block)
        # # NOTE: probably do NOT want this, but it's need for Workflows for now.
        # elsif out.respond_to?(method_name)
        #   out.send(method_name, *args[1..-1], &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        out.respond_to?(method_name) || super
      end

      private

      def out
        @out
      end

      def err
        @err
      end

      def stdout
        out.instance_variable_get(:'@output')
      end

      def stderr
        err.instance_variable_get(:'@output')
      end
    end
  end
end
