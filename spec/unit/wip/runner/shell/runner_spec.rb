require 'spec_helper'

module WIP::Runner
  describe Shell::Runner do
    subject(:runner) { Shell::Runner.new(ui, task, {}) }
    let(:options)    { Options.new }
    let(:task) do
      Shell::Task.new(nil) do |arguments, options|
        config :VARIABLE
        shell :script, %{
          echo $VARIABLE
        }
      end
    end

    describe 'Given a Task with prompts' do
      before do
        simulate(
          "- VARIABLE: " => 'input'
        )
      end

      context 'when the Task is run in "execute" mode' do
        it 'writes prompts to STDERR' do
          expect { simulate { runner.run(nil, options) } }.to show %(
            Config...
            - VARIABLE:

            Shell script...
          ), :to => :err
        end

        it 'writes script output to STDOUT' do
          simulate(
            "- VARIABLE: " => 'input'
          )

          expect { simulate { runner.run(nil, options) } }.to show %(
            echo $VARIABLE

            > input
          ), :to => :out
        end
      end

      context 'when the Task is run in "preview" mode' do
        # TODO...
      end
    end
  end
end
