require 'spec_helper'

module WIP::Runner
  describe CLI::Help do
    subject(:command) { CLI::Version.new(io) }

    describe '#run' do
      it 'executes' do
        expect { command.run }.to show 'wip-runner version', :match => :partial
      end
    end
  end
end
