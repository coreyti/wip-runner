require 'spec_helper'

module WIP::Runner
  describe Shell::Runner do
    subject(:runner) { Shell::Runner.new(ui, env) }
    let(:execution)  { simulate { runner.run(task, arguments, options) } }
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
      ENV['VARIABLE'] = 'value from ENV'
    end

    after do
      ENV.delete('VARIABLE')
    end

    describe '#run' do
      context 'called with default options' do
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

      context 'called with mode: "execute"' do
        let(:options) { Options.new({ :mode => :execute, :interactive => true })}

        before do
          simulate(
            "- VARIABLE: " => 'value from user'
          )
        end

        it 'writes prompts to STDERR' do
          expect { execution }.to show %(
            - VARIABLE: |value from ENV|
          ), :to => :err
        end

        it 'writes content and results to STDOUT' do
          expect { execution }.to show %(
            echo $VARIABLE

            > value from user
          ), :to => :out
        end
      end

      context 'called with mode: "execute + non-interactive"' do
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

      context 'called with mode: "display"' do
        let(:options) { Options.new({ :mode => :display, :interactive => true })}

        before do
          simulate(
            "- VARIABLE: " => 'value from user'
          )
        end

        it 'writes prompts to STDERR' do
          expect { execution }.to show %(
            - VARIABLE: |value from ENV|
          ), :to => :err
        end

        it 'writes content to STDOUT (without execution)' do
          expect { execution }.to show %(
            echo $VARIABLE
          ), :to => :out
        end
      end

      context 'called with mode: "display + non-interactive"' do
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

      context 'called with mode: "silent"' do
        let(:options) { Options.new({ :mode => :silent, :interactive => true })}

        before do
          simulate(
            "- VARIABLE: " => 'value from user'
          )
        end

        it 'writes prompts to STDERR' do
          expect { execution }.to show %(
            - VARIABLE: |value from ENV|
          ), :to => :err
        end

        it 'does not write to STDOUT' do
          expect { execution }.to_not show 'value', :to => :out, :match => :partial
        end
      end

      context 'called with mode: "display + non-interactive"' do
        let(:options) { Options.new({ :mode => :display, :interactive => false })}

        it 'does not write prompts to STDERR' do
          expect { execution }.to_not output.to_stderr
        end

        it 'does not write to STDOUT' do
          expect { execution }.to_not output.to_stdout
        end
      end

      context 'called with format: markdown' do
        it 'is PENDING'
      end

      context 'called with format: x' do
        it 'is PENDING'
      end

      context 'called with @env' do
        let(:env) { { 'VARIABLE' => 'value from @env' } }

        before do
          simulate(
            "- VARIABLE: " => nil
          )
        end

        it 'sets config defaults from @env' do
          expect { execution }.to show %(
            - VARIABLE: |value from @env|

            echo $VARIABLE

            > value from @env
          )
        end
      end

      context 'called with a block' do
        let(:task) do
          Shell::Task.new(nil) do |arguments, options|
            shell :script, %{
              echo content
            }
          end
        end

        it 'yields content to the block' do
          buffer = StringIO.new
          options.echo = false

          expect {
            runner.run(task, arguments, options) do |line|
              buffer.puts line
            end
          }.to_not show('content', :match => :partial)
          expect(buffer.string.strip).to eq('content')
        end
      end

      context 'called multiple times' do
        let(:task1) do
          Shell::Task.new(nil) do |arguments, options|
            config :VARIABLE
          end
        end
        let(:task2) do
          Shell::Task.new(nil) do |arguments, options|
            shell :script, %{
              echo $VARIABLE
            }
          end
        end

        before do
          simulate(
            "- VARIABLE: " => 'value from user'
          )
        end

        it 'propagates config settings' do
          simulate { runner.run([task1], arguments, options) }
          expect   { runner.run([task2], arguments, options) }
            .to show %(
              echo $VARIABLE

              > value from user
            )
        end
      end

      context 'when executed with a failing `shell :script`' do
        let(:task) do
          Shell::Task.new(nil) do |arguments, options|
            shell :script, %{
              echo 'this will fail...'
              exit 42
            }
          end
        end

        it 'writes results to STDERR' do
          expect { execution }.to raise_error(SystemExit)
          .and show %(
            Failure (exit code 42)

            this will fail...
          ), :to => :err
        end
      end
    end

    # NOTE: this is more about Task definition
    context 'when executed with config :default' do
      let(:env) { { 'VARIABLE' => 'value from @env' } }
      let(:task) do
        Shell::Task.new(nil) do |arguments, options|
          config :VARIABLE, :default => 'value from default'
          shell :script, %{
            echo $VARIABLE
          }
        end
      end

      before do
        simulate(
          "- VARIABLE: " => nil
        )
      end

      it 'sets config defaults from provided default' do
        expect { execution }.to show %(
          - VARIABLE: |value from default|

          echo $VARIABLE

          > value from default
        )
      end
    end

    context 'given nested tasks, with headings' do
      let(:task) do
        Shell::Task.new(nil) do |arguments, options|
          task('Config heading') do
            config :VARIABLE, :default => 'value from default'
          end

          task('Script heading') do
            shell :script, %{
              echo $VARIABLE
            }
          end
        end
      end

      before do
        simulate(
          "- VARIABLE: " => 'value from user'
        )
      end

      it 'writes the headings to STDERR' do
        expect { execution }.to show %(
          Config heading

          - VARIABLE: |value from default|


          Script heading
        ), :to => :err
      end
    end

    # pending 'UI Simulator handling of password/echo(false)'
    xcontext 'when executed with config :password mode' do
      let(:env) { { 'VARIABLE' => 'value from @env' } }
      let(:task) do
        Shell::Task.new(nil) do |arguments, options|
          config :VARIABLE, :password => true
          shell :script, %{
            echo $VARIABLE
          }
        end
      end

      before do
        simulate(
          "- VARIABLE: " => nil
        )
      end

      it 'does not print the default' do
        expect { execution }.to show %(
          - VARIABLE:

          echo $VARIABLE

          > value from @env
        )
      end
    end
  end
end
