require 'spec_helper'

module WIP::Runner
  describe Shell::Runner do
    subject(:runner) { Shell::Runner.new(ui, task, env) }
    let(:execution)  { runner.run(arguments, options) }
    let(:execute)    { execution }
    let(:arguments)  { Options.new }
    let(:options)    { Options.new }
    let(:env)        { {} }
    let(:task) do
      Shell::Task.new(nil) do |arguments, options|
        config :VARIABLE
        shell :script, %{
          echo $VARIABLE
        }
      end
    end

    before do
      # TODO: move this to the top-level. it should be used for non-interactive.
      ENV['VARIABLE'] = 'value from ENV'
    end

    after do
      ENV.delete('VARIABLE')
    end

    context 'when executed with default options' do
      let(:task) { Shell::Task.new(nil) { |arguments, options| } }

      it 'defaults to mode: "execute"' do
        execute
        expect(runner.options.mode)
          .to eq(:execute)
      end

      it 'defaults to interactive' do
        execute
        expect(runner.options.interactive)
          .to eq(true)
      end

      it 'defaults to format: "text"' do
        execute
        expect(runner.options.format)
          .to eq(:text)
      end
    end

    context 'when executed with mode: "execute"' do
      let(:execution) { simulate { runner.run(arguments, options) } }
      let(:options)   { Options.new({ :mode => :execute, :interactive => true })}

      before do
        simulate(
          "- VARIABLE: " => 'value from user'
        )
      end

      it 'writes prompts to STDERR' do
        expect { execution }.to show %(
          - VARIABLE:  |value from ENV|
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
      let(:options) { Options.new({ :mode => :execute, :interactive => false })}

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
      let(:execution) { simulate { runner.run(arguments, options) } }
      let(:options)   { Options.new({ :mode => :display, :interactive => true })}

      before do
        simulate(
          "- VARIABLE: " => 'value from user'
        )
      end

      it 'writes prompts to STDERR' do
        expect { execution }.to show %(
          - VARIABLE:  |value from ENV|
        ), :to => :err
      end

      it 'writes content to STDOUT (without execution)' do
        expect { execution }.to show %(
          echo $VARIABLE
        ), :to => :out
      end
    end

    context 'when executed with mode: "display + non-interactive"' do
      let(:options) { Options.new({ :mode => :display, :interactive => false })}

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

    context 'when executed with @env' do
      let(:execution) { simulate { runner.run(arguments, options) } }
      let(:env)       { { 'VARIABLE' => 'value from @env' } }

      before do
        simulate(
          "- VARIABLE: " => nil
        )
      end

      it 'sets config defaults from @env' do
        expect { execution }.to show %(
          - VARIABLE:  |value from @env|

          echo $VARIABLE

          > value from @env
        )
      end
    end
  end
end
