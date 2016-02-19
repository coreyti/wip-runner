require 'highline'

module WIP
  module Runner
    class UI
      def initialize(input = $stdin, out = $stdout, err = $stderr)
        @out = HighLine.new(input, out, nil, nil, 2, 0)
        @err = HighLine.new(input, err, nil, nil, 2, 0)
      end

      def err
        if block_given?
          current = @output
          @output = @err
          result  = yield
          @output = current
          result
        else
          @err
        end
      end

      def out
        if block_given?
          current = @output
          @output = @out
          result  = yield
          @output = current
          result
        else
          @out
        end
      end

      def indent(*args, &block)
        increase = args.shift || 1
        @out.indent_level += increase
        @err.indent_level += increase
        @output.indent(0, *args, &block)
        @out.indent_level -= increase
        @err.indent_level -= increase
      end

      def indent_level=(level)
        @out.indent_level = level
        @err.indent_level = level
      end

      protected

      def method_missing(method_name, *args, &block)
        if @output.respond_to?(method_name)
          @output.send(method_name, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        @output.respond_to?(method_name) || super
      end

      # private
      #
      # def stdout
      #   out.instance_variable_get(:'@output')
      # end
      #
      # def stderr
      #   err.instance_variable_get(:'@output')
      # end
      #
      # def toggle(stream)
      #   send((stream == :out) ? :err : :out)
      # end
    end
  end
end

# par ce que, je n'aime pas le "stream"...
# ???
#
# ui.out {
#   indent do
#     ask(...)
#     say(...)
#   end
#
#   err { ???
#     ...
#   }
# }
#
# ui.err {
#   ...
# }
#
# OR...
#
# ui.target(:out)
# ui.say


# def indent(stream, increase = 1, statement = nil, multiline = nil, &block)
#   toggle(stream).indent_level += increase
#   send(stream).indent(increase, statement, multiline, &block)
#   toggle(stream).indent_level -= increase
# end

# def indent(*args, &block)
#   # args.shift if args.first.is_a?(Symbol)
#   # @out.indent(*args, &block)
#   # @err.indent(*args, &block)
#   @out.indent(*args[1..-1], &block)
#   @err.indent(*args[1..-1], &block)
# end
