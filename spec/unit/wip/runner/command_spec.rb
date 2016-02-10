require 'spec_helper'

module WIP::Runner
  describe Command do
    describe '#run' do
      let(:command) { example_command(:Simple) }

      it 'executes' do
        expect { command.run }.to change { command.executed? }
      end

      context 'given options as "--help"' do
        it 'prints help' do
          expect { command.run(['--help']) }.to show %(
            Usage: wip-runner simple [options]

            Options:
                -h, --help                       Prints help messages
          ), :to => :err
          expect(command).to_not be_executed
        end
      end

      context 'when the Command defines options' do
        let(:command) { example_command(:WithOptions) }

        it 'executes' do
          expect { command.run }.to change { command.executed? }
          expect(command.flagged).to be(false)
        end

        context 'given valid options' do
          it 'executes with the options provided' do
            expect { command.run(['--flag']) }.to change { command.executed? }
            expect(command.flagged).to be(true)
          end
        end

        context 'given invalid options' do
          it 'prints help' do
            expect { command.run(['--bogus']) }.to show %(
              Invalid option: --bogus

              Usage: wip-runner with-options [options]

              Options:
                  -f, --flag                       Option 1
                  -h, --help                       Prints help messages
            ), :to => :err
            expect(command).to_not be_executed
          end
        end
      end

      context 'when the Command defines arguments' do
        let(:command) { example_command(:WithArguments) }

        it 'executes' do
          expect { command.run(['A', 'B']) }.to change { command.executed? }
        end

        context 'given invalid arguments' do
          it 'prints help' do
            expect { command.run(['A']) }.to show %(
              Invalid arguments:
                  - arg_02 ... (missing)

              Usage: wip-runner with-arguments <arguments> [options]

              Arguments:
                  arg_01                           Argument 1
                  arg_02                           Argument 2

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
            expect(command).to_not be_executed
          end
        end

        context 'given options as "--help"' do
          it 'prints help' do
            expect { command.run(['--help']) }.to show %(
              Usage: wip-runner with-arguments <arguments> [options]

              Arguments:
                  arg_01                           Argument 1
                  arg_02                           Argument 2

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
            expect(command).to_not be_executed
          end
        end
      end

      context 'when the Command defines nested Commands' do
        let(:command) { example_command(:WithNested) }

        it 'executes' do
          expect { command.run(['nested']) }.to show 'running nested command...'
        end

        context 'when the sub-command is called with "--help"' do
          it 'prints help' do
            expect { command.run(['nested', '--help']) }.to show %(
              Usage: wip-runner with-nested nested [options]

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
          end
        end

        context 'when the sub-command is called incorrectly' do
          it 'prints help' do
            expect { command.run(['nested', '--bogus']) }.to show %(
              Invalid option: --bogus

              Usage: wip-runner with-nested nested [options]

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
          end
        end

        context 'when the sub-command is missing' do
          it 'prints help' do
            expect { command.run([]) }.to show %(
              Invalid command: (missing)

              Usage: wip-runner with-nested <command> <arguments> [options]

              Commands:
                  nested                           A nested command

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
          end
        end

        context 'when the sub-command is invalid' do
          it 'prints help' do
            expect { command.run(['bogus']) }.to show %(
              Invalid command: bogus

              Usage: wip-runner with-nested <command> <arguments> [options]

              Commands:
                  nested                           A nested command

              Options:
                  -h, --help                       Prints help messages
            ), :to => :err
          end
        end
      end
    end
  end
end
