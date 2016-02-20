require 'spec_helper'

module WIP::Runner
  describe UI do
    subject(:ui) { UI.new($stdin, $stdout, $stderr) }

    describe '#out' do
      it 'is a HighLine instance, with output to :stdout' do
        highline = ui.out
        output   = highline.instance_variable_get(:'@output')

        expect(highline)
          .to be_a HighLine
        expect(output)
          .to be $stdout
      end

      context 'given a block' do
        it 'is evaluated with output directed to :stdout' do
          expect do
            ui.out { ui.say 'message to stdout' }
          end.to output("message to stdout\n").to_stdout
        end

        it 'restores the output stream after execution' do
          ui.instance_variable_set('@output', ui.err)

          expect do
            ui.out {
              ui.say 'message to stdout'
            }
          end.to show("message to stdout\n", :to => :out)

          expect do
            ui.say 'message to stderr'
          end.to show("message to stderr\n", :to => :err)
        end
      end
    end

    describe '#err' do
      it 'is a HighLine instance, with output to :stderr' do
        highline = ui.err
        output   = highline.instance_variable_get(:'@output')

        expect(highline)
          .to be_a HighLine
        expect(output)
          .to be $stderr
      end

      context 'given a block' do
        it 'is evaluated with output directed to :stderr' do
          expect do
            ui.err { ui.say 'message' }
          end.to output("message\n").to_stderr
        end

        it 'restores the output stream after execution' do
          ui.instance_variable_set('@output', ui.out)

          expect do
            ui.err {
              ui.say 'message to stderr'
            }
          end.to show("message to stderr\n", :to => :err)

          expect do
            ui.say 'message to stdout'
          end.to show("message to stdout\n", :to => :out)
        end
      end
    end
  end
end
