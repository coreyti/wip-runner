require 'spec_helper'

module WIP::Runner
  describe Shell::Runner do
    subject(:runner) { Shell::Runner.new(task, {}) }
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

      it 'writes prompts to STDERR' do
        expect { simulate { runner.run(nil, options) } }.to show %(

        ) #, :output => :stderr
      end

      it 'writes script output to STDOUT' do
        simulate(
          "- VARIABLE: " => 'input'
        )

        expect { simulate { runner.run(nil, options) } }.to show %(
          > input
        )
      end
    end
  end
end
