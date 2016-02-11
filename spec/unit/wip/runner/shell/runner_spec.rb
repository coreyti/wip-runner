require 'spec_helper'

module WIP::Runner
  describe Shell::Runner do
    subject(:runner) { Shell::Runner.new(ui, task, {}) }
    let(:env) { { :VARIABLE => 'value from env' } }
    let(:task) do
      Shell::Task.new(nil) do |arguments, options|
        config :VARIABLE
        shell :script, %{
          echo $VARIABLE
        }
      end
    end

    context 'when executed with mode: "execute"' do
      let(:execution) { simulate { runner.run(nil, options) } }
      let(:options)   { Options.new({ :mode => :execute, :interactive => true })}

      before do
        simulate(
          "- VARIABLE: " => 'value from user'
        )
      end

      it 'writes prompts to STDERR' do
        expect { execution }.to show %(
          - VARIABLE:
        ), :to => :err
      end

      it 'writes content and results to STDOUT' do
        expect { execution }.to show %(
          echo $VARIABLE

          > value from user
        ), :to => :out
      end
    end

    context 'when executed with mode: "execute + non-interactive"' do
      let(:execution) { runner.run(nil, options) }
      let(:options)   { Options.new({ :mode => :execute, :interactive => false })}

      before do
        # TODO: move this to the top-level. it should be used for non-interactive.
        ENV['VARIABLE'] = 'value from ENV'
      end

      after do
        ENV.delete('VARIABLE')
      end

      it 'does not write prompts to STDERR' do
        expect { execution }.to_not output.to_stderr
      end

      it 'writes content and results to STDOUT' do
        expect { execution }.to show %(
          echo $VARIABLE

          > value from ENV
        ), :to => :out
      end
    end

    context 'when executed with mode: "display"' do
      let(:execution) { simulate { runner.run(nil, options) } }
      let(:options)   { Options.new({ :mode => :display, :interactive => true })}

      before do
        simulate(
          "- VARIABLE: " => 'value from user'
        )
      end

      it 'writes prompts to STDERR' do
        expect { execution }.to show %(
          - VARIABLE:
        ), :to => :err
      end

      it 'writes content to STDOUT (without execution)' do
        expect { execution }.to show %(
          echo $VARIABLE
        ), :to => :out
      end
    end

    context 'when executed with mode: "display + non-interactive"' do
      let(:execution) { runner.run(nil, options) }
      let(:options)   { Options.new({ :mode => :display, :interactive => false })}

      before do
        # TODO: move this to the top-level. it should be used for non-interactive.
        ENV['VARIABLE'] = 'value from ENV'
      end

      after do
        ENV.delete('VARIABLE')
      end

      it 'does not write prompts to STDERR' do
        expect { execution }.to_not output.to_stderr
      end

      it 'writes content to STDOUT (without execution)' do
        expect { execution }.to show %(
          echo $VARIABLE
        ), :to => :out
      end
    end

    context 'when executed with format: markdown' do

    end

    context 'when executed with format: x' do

    end
  end
end
