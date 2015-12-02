require 'spec_helper'

module WIP::Runner
  describe CLI::Help do
    subject(:command) { CLI::Help.new(io) }

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

      context 'given nil/empty arguments' do
        it 'prints help' do
          expect { command.run }.to show help
        end
      end

      context 'given arguments' do
        context 'as a valid command' do
          it 'prints help for the command' do
            expect { command.run(['version']) }.to show %(
              Usage: wip-runner version [options]

              Options:
                  -h, --help                       Prints help messages
            )
          end
        end

        context 'as a bogus command' do
          it 'prints general help' do
            expect { command.run(['bogus']) }.to show %(
              Invalid command: bogus

              Usage: wip-runner help <arguments> [options]
            ), :match => :partial
          end
        end
      end
    end
  end
end
