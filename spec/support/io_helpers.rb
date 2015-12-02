module Support
  def io
    @io ||= CustomHighLine.new
  end

  def simulate(pairs = nil)
    unless pairs.nil?
      @simulated = pairs.inject(@simulated || {}) do |memo, (q, a)|
        memo[q] = a ; memo
      end
    end

    if block_given?
      begin
        originput = io.instance_variable_get(:@input)
        simulator = Simulator.new(@simulated.values, (@simulated.keys == ['*']))
        io.instance_variable_set(:@input, simulator)

        @simulated.keys.each do |question|
          # NOTE: the "|default|" is stripped because that is added
          # later by the Question instance, in time for a call to #say.
          if question.is_a?(Array)
            expect(io).to receive(:ask)
              .with(*question)
              .and_call_original
          else
            question = question.sub(/:\s\|.*\Z/, ': ')
            expect(io).to receive(:ask)
              .with(question)
              .and_call_original
          end unless question == '*'
        end

        yield
      ensure
        io.instance_variable_set(:@input, originput)
      end
    end
  end

  private

  class CustomHighLine < HighLine
    # Strips the same-line indicating, trailing space from questions in order
    # to print the newline in specs (that would come from user input).
    def ask(question, answer_type = String, &block)
      super("#{question.rstrip}", answer_type, &block)
    end

    # Strips double spaces between question and default.
    def say(statement)
      # puts statement.to_s.inspect
      super statement.to_s.gsub(/:\s{2,}\|/, ': |')
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