require 'spec_helper'

module WIP::Runner
  describe CLI::Help do
    subject(:command) { CLI::Version.new(ui) }

    describe '#run' do
      it 'executes' do
        expect { command.run }.to show 'wip-runner version',
          :to    => :out,
          :match => :partial
      end
    end
  end
end
