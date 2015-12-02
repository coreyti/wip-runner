require 'spec_helper'

module WIP::Runner
  describe CLI do
    subject(:cli) { CLI.new(io) }

    describe '#run' do
      let(:help) do
        %(
          Usage: wip-runner <command> [options]

          Commands:
              help                             Prints help messages
              version                          Prints version information

          Options:
              -h, --help                       Prints help messages
        )
      end

      context 'given no arguments' do
        it 'prints help' do
          expect { cli.run }.to show help
        end
      end

      context 'given empty arguments' do
        it 'prints help' do
          expect { cli.run([]) }.to show help
        end
      end

      context 'given arguments as "--help"' do
        it 'prints help' do
          expect { cli.run(['--help']) }.to show help
        end
      end

      context 'given command arguments' do
        context 'as "help"' do
          it 'prints help' do
            expect { cli.run(['help']) }.to show help
          end
        end

        context 'as "version"' do
          it 'executes the command' do
            expect { cli.run(['version']) }.to show %(
              wip-runner version #{WIP::Runner::VERSION}
            )
          end
        end

        context 'as "help version"' do
          it 'executes the command' do
            expect { cli.run(['help', 'version']) }.to show %(
              Usage: wip-runner version [options]

              Options:
                  -h, --help                       Prints help messages
            )
          end
        end

        context 'as "bogus"' do
          it 'prints help' do
            expect { cli.run(['bogus']) }.to show %(
              Invalid command: bogus

              Usage: wip-runner <command> [options]
            ), :match => :partial
          end
        end
      end
    end
  end
end
