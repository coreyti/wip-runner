module WIP
  module Runner::Spec
    module Helpers::UIHelpers
      def ui
        @ui ||= CustomUI.new($stdin, StringIO.new, StringIO.new)
      end

      def simulate(pairs = nil)
        unless pairs.nil?
          @simulated = pairs.inject(@simulated || []) do |memo, pair|
            memo << pair ; memo
          end
        end

        if block_given?
          highline = ui.err
          original = highline.instance_variable_get(:@input)

          begin
            if @simulated
              keys      = @simulated.map { |pair| pair[0] }
              values    = @simulated.map { |pair| pair[1] }
              simulator = Simulator.new(values, (@simulated[0][0] == '*'))
              highline.instance_variable_set(:@input, simulator)

              keys.each do |question|
                # NOTE: the "|default|" is stripped because that is added
                # later by the Question instance, in time for a call to #say.
                if question.is_a?(Array)
                  expect(highline).to receive(:ask)
                    .with(*question)
                    .and_call_original
                else
                  question = question.sub(/:\s\|.*\Z/, ': ')
                  expect(highline).to receive(:ask)
                    .with(question)
                    .and_call_original
                end unless question == '*'
              end
            end

            yield
          ensure
            highline.instance_variable_set(:@input, original)
          end
        end
      end

      private

      class CustomUI < WIP::Runner::UI
        def initialize(input, out, err)
          @out = CustomLine.new(input, out, nil, nil, 2, 0)
          @err = CustomLine.new(input, err, nil, nil, 2, 0)
        end
      end

      class CustomLine < HighLine
        # Strips the same-line indicating, trailing space from questions in order
        # to print the newline in specs (that would come from user input).
        def ask(question, answer_type = String, &block)
          super("#{question.rstrip}", answer_type, &block)
        end

        # Strips double spaces between question and default.
        def say(statement)
          super(statement.to_s.gsub(/:\s{2,}\|/, ': |'))
        end

        # Strips formatting for specs.
        def color(string, *colors)
          string
        end
      end

      # adapted from https://gist.github.com/194554
      class Simulator
        def initialize(values, all = false)
          @values = values.map { |s| s.nil? ? '' : s }
          @all    = all
        end

        def gets
          @all ? @values.first : @values.shift
        end

        def eof?
          false
        end
      end
    end
  end
end
