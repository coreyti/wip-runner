require 'spec_helper'

module WIP::Runner
  describe Workflow do
    describe '.define' do
    end

    describe '#execute' do
      let(:command) { command_class.new(io) }

      context 'given an empty definition' do
        let(:command_class) {
          define_command do
            workflow {}
          end
        }

        it 'executes' do
          expect { command.run }.to_not raise_error
        end
      end

      context 'given an overview' do
        let(:command_class) {
          define_command do
            overview 'An Overview'
            workflow {}
          end
        }

        it 'executes' do
          expect { command.run }.to show %(
            # Command Workflow

            An Overview
          )
        end
      end

      context 'given a prologue' do
        let(:command_class) {
          define_command do
            workflow do
              prologue 'Prologue text'
            end
          end
        }

        it 'executes' do
          expect { command.run }.to show %(
            # Command Workflow

            Prologue text
          )
        end
      end

      context 'given an overview and a prologue' do
        let(:command_class) {
          define_command do
            overview 'An Overview'

            workflow do
              prologue %(
                Multi-line
                prologue text
              )
            end
          end
        }

        it 'executes' do
          expect { command.run }.to show %(
            # Command Workflow

            An Overview

            Multi-line
            prologue text
          )
        end
      end

      context 'given configs' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              config :HOME
              config :OPTIONAL
              config :DEFAULT1, default: 'default value 1'
              config :DEFAULT2, default: 'default value 2'

              task 'Echo config' do
                shell :script, %(
                  for e in "HOME" "OPTIONAL" "DEFAULT1" "DEFAULT2" ; do
                    echo $e is: ${!e}
                  done
                )
              end
            end
          end
        }
        let(:menu) { ["Ignored", ["yes", "no", "skip", "step", "preview"]] }

        it 'executes' do
          simulate(
            "- HOME: |#{ENV['HOME']}|" => nil,
            "- OPTIONAL: "             => nil,
            "- DEFAULT1: "             => nil,
            "- DEFAULT2: "             => 'user input',
            menu                       => 'yes'
          )

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Configuration

              Please provide values for the following...
              - HOME: |#{ENV['HOME']}|
              - OPTIONAL:
              - DEFAULT1: |default value 1|
              - DEFAULT2: |default value 2|

            ## Echo config

              Steps...

              ```
              for e in "HOME" "OPTIONAL" "DEFAULT1" "DEFAULT2" ; do
                echo $e is: ${!e}
              done
              ```

              Continue?:
              yes, no, skip, step or preview?\s\s
              ```
              for e in "HOME" "OPTIONAL" "DEFAULT1" "DEFAULT2" ; do
                echo $e is: ${!e}
              done
              ```
                ⫶ HOME is: /Users/corey
                ⫶ OPTIONAL is:
                ⫶ DEFAULT1 is: default value 1
                ⫶ DEFAULT2 is: user input
          )
        end
      end

      context 'given guards' do
        context 'when the check exits non-zero' do
          let(:command_class) {
            define_command do
              workflow do |arguments, options|
                guard 'things are not hopeless', 'exit 1'
                task  'Will not get here'
              end
            end
          }

          it 'blocks execution' do
            expect { command.run }.to show %(
              # Command Workflow

              Guard failed: 'things are not hopeless'
                → exit 1
              Exit code was 1
            )
          end
        end

        context 'when the check exits 0' do
          context 'and the expectation is nil' do
            let(:command_class) {
              define_command do
                workflow do |arguments, options|
                  guard 'need a response', 'echo "response"'
                  task  'Perform task A'
                end
              end
            }

            it 'allows executions' do
              simulate('*' => 'yes')

              expect { simulate { command.run([nil]) } }.to show %(
                # Command Workflow

                ## Perform task A

                  Continue?:
                  yes, no, skip, step or preview?
              )
            end
          end

          context 'and the expectation is an equivalent String' do
            let(:command_class) {
              define_command do
                workflow do |arguments, options|
                  guard 'need a response', 'echo "response"', 'response'
                  task  'Perform task A'
                end
              end
            }

            it 'allows executions' do
              simulate('*' => 'yes')

              expect { simulate { command.run([nil]) } }.to show %(
                # Command Workflow

                ## Perform task A

                  Continue?:
                  yes, no, skip, step or preview?
              )
            end
          end

          context 'and the expectation is an inequivalent String' do
            let(:command_class) {
              define_command do
                workflow do |arguments, options|
                  guard 'need a response', 'echo "response"', 'resp'
                  task  'Perform task A'
                end
              end
            }

            it 'blocks executions' do
              expect { command.run([nil]) }.to show %(
                # Command Workflow

                Guard failed: 'need a response'
                  → echo "response"
                Output did not equal expected

                Expected:
                  resp

                Actual:
                  response
              )
            end
          end

          context 'and the expectation is a match Regexp' do
            let(:command_class) {
              define_command do
                workflow do |arguments, options|
                  guard 'need a response', 'echo "response"', /resp/
                  task  'Perform task A'
                end
              end
            }

            it 'allows executions' do
              simulate('*' => 'yes')

              expect { simulate { command.run([nil]) } }.to show %(
                # Command Workflow

                ## Perform task A

                  Continue?:
                  yes, no, skip, step or preview?
              )
            end
          end

          context 'and the expectation is a mismatched Regexp' do
            let(:command_class) {
              define_command do
                workflow do |arguments, options|
                  guard 'need a response', 'echo "silence"', /resp/
                  task  'Perform task A'
                end
              end
            }

            it 'blocks executions' do
              expect { command.run([nil]) }.to show %(
                # Command Workflow

                Guard failed: 'need a response'
                  → echo "silence"
                Output did not match expected

                Expected:
                  /resp/

                Actual:
                  silence
              )
            end
          end
        end
      end

      context 'given configs and guards' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              config :CONFIG
              guard  'needs proper config', 'echo $CONFIG', 'proper'
            end
          end
        }

        it 'processes the configs prior to the guards' do
          simulate(
            '- CONFIG: ' => 'unsuitable answer'
          )

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Configuration

              Please provide values for the following...
              - CONFIG:

            Guard failed: 'needs proper config'
              → echo $CONFIG
            Output did not equal expected

            Expected:
              proper

            Actual:
              unsuitable answer
          )
        end
      end

      context 'given tasks & steps' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Perform task A'
              task 'Perform task B' do
                step 'Perform step B1'
                step 'Perform step B2'
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Perform task A

              Continue?:
              yes, no, skip, step or preview?\s\s
            ## Perform task B

              Steps...

              - [ ] Perform step B1

              - [ ] Perform step B2

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] Perform step B1

              - [ ] Perform step B2
          )
        end
      end

      context 'given `shell :script`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              shell :script, %(
                help () {
                  echo Helping $1
                }

                help "with text"
              )
            end
          end
        }

        it 'executes' do
          expect { command.run }.to show %(
            # Command Workflow

            ```
            help () {
              echo Helping $1
            }

            help "with text"
            ```
              ⫶ Helping with text
          )
        end
      end

      context 'given `shell :lines`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              shell :lines, %(
                echo Line one
                echo Line two
              )
            end
          end
        }

        it 'executes' do
          expect { command.run }.to show %(
            # Command Workflow

            → echo Line one
              ⫶ Line one

            → echo Line two
              ⫶ Line two
          )
        end
      end

      context 'given `shell :source`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              shell :source, %(
                export VARIABLE=value
              )

              task 'Task A' do
                shell :lines, %(
                  echo $VARIABLE
                )
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              → echo $VARIABLE

              Continue?:
              yes, no, skip, step or preview?\s\s
              → echo $VARIABLE
                ⫶ value
          )
        end
      end

      context 'given a task with `shell :script`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                shell :script, %(
                  help () {
                    echo Helping $1
                  }

                  help "with text"
                )
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              ```
              help () {
                echo Helping $1
              }

              help "with text"
              ```

              Continue?:
              yes, no, skip, step or preview?\s\s
              ```
              help () {
                echo Helping $1
              }

              help "with text"
              ```
                ⫶ Helping with text
          )
        end
      end

      context 'given a task with `shell :lines`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                shell :lines, %(
                  echo Line one
                  echo Line two
                )
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              → echo Line one
              → echo Line two

              Continue?:
              yes, no, skip, step or preview?\s\s
              → echo Line one
                ⫶ Line one

              → echo Line two
                ⫶ Line two
          )
        end
      end

      context 'given a task with `shell :source`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                shell :source, %(
                  export VARIABLE=value
                )

                shell :lines, %(
                  echo $VARIABLE
                )
              end

              task 'Task B' do
                shell :lines, %(
                  echo $VARIABLE
                )
              end
            end
          end
        }

        it 'executes, without sourcing across task boundaries' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              → echo $VARIABLE

              Continue?:
              yes, no, skip, step or preview?\s\s
              → echo $VARIABLE
                ⫶ value

            ## Task B

              Steps...

              → echo $VARIABLE

              Continue?:
              yes, no, skip, step or preview?\s\s
              → echo $VARIABLE
                ⫶
          )
        end
      end

      context 'given a step with `shell :script`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                step 'Step one' do
                  shell :script, %(
                    help () {
                      echo Helping $1
                    }

                    help "with text"
                  )
                end
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              - [ ] Step one

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] Step one

                ```
                help () {
                  echo Helping $1
                }

                help "with text"
                ```
                  ⫶ Helping with text
          )
        end
      end

      context 'given a step with `shell :lines`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                step 'Step one' do
                  shell :lines, %(
                    echo Line one
                    echo Line two
                  )
                end
              end
            end
          end
        }

        it 'executes' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              - [ ] Step one

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] Step one

                → echo Line one
                  ⫶ Line one

                → echo Line two
                  ⫶ Line two
          )
        end
      end

      context 'given a step with `shell :source`' do
        let(:command_class) {
          define_command do
            workflow do |arguments, options|
              task 'Task A' do
                step 'Step one' do
                  shell :source, %(
                    export VARIABLE=value
                  )

                  shell :lines, %(
                    echo $VARIABLE
                  )
                end
              end

              task 'Task B' do
                step 'Step two' do
                  shell :lines, %(
                    echo $VARIABLE
                  )
                end
              end
            end
          end
        }

        it 'executes, without sourcing across task boundaries' do
          simulate('*' => 'yes')

          expect { simulate { command.run } }.to show %(
            # Command Workflow

            ## Task A

              Steps...

              - [ ] Step one

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] Step one

                → echo $VARIABLE
                  ⫶ value

            ## Task B

              Steps...

              - [ ] Step two

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] Step two

                → echo $VARIABLE
                  ⫶
          )
        end
      end

      context 'called with arguments' do
        let(:command_class) {
          define_command do
            argument :message, {}

            workflow do |arguments, options|
              heading = "So... #{arguments.message}"
              task heading
            end
          end
        }

        it 'executes with context' do
          simulate('*' => 'yes')

          expect { simulate { command.run(["Here's a little story"]) } }.to show %(
            # Command Workflow

            ## So... Here's a little story

              Continue?:
              yes, no, skip, step or preview?
          )
        end
      end

      context 'called with options' do
        let(:command_class) {
          define_command do
            options do |parser, config|
              config.flagged = false

              parser.on('--flag') do
                config.flagged = true
              end
            end

            workflow do |arguments, options|
              heading = options.flagged ? 'Flagged content' : 'Content'
              task heading
            end
          end
        }

        it 'executes with context' do
          simulate('*' => 'yes')

          expect { simulate { command.run(['--flag']) } }.to show %(
            # Command Workflow

            ## Flagged content

              Continue?:
              yes, no, skip, step or preview?
          )
        end
      end

      context 'called with --continue' do
        xit 'is pending' do

        end
      end

      context 'called with --non-interactive' do
        xit 'is pending' do

        end
      end

      context 'called with --overview' do
        let(:command_class) {
          define_command do
            overview 'An example workflow'

            workflow do |arguments, options|
              prologue %(
                Some longer introductory
                text for the example workflow.
              )

              task 'Will not run'
            end
          end
        }

        it 'prints an overview' do
          expect { command.run(['--overview']) }.to show %(
            # Command Workflow

            An example workflow

            Some longer introductory
            text for the example workflow.
          )
        end
      end

      context 'called with --preview' do
        let(:command_class) {
          define_command do
            overview 'An example workflow'

            workflow do |arguments, options|
              prologue %(
                Some longer introductory
                text for the example workflow.
              )

              task 'Task A' do
                prologue 'Will not run'

                shell :lines, %(
                  exit 1
                )

                step 'Step one' do
                  prologue 'Will not run'

                  shell :lines, %(
                    exit 1
                  )
                end
              end
            end
          end
        }

        it 'prints a preview' do
          expect { command.run(['--preview']) }.to show %(
            # Command Workflow

            An example workflow

            Some longer introductory
            text for the example workflow.

            ## Task A

              Will not run

              Steps...

              → exit 1

              - [ ] Step one

                Will not run

                → exit 1
          )
        end
      end

      context 'called with --progress' do
        xit 'is pending' do

        end
      end

      describe 'invocation' do
        let(:command_class) {
          define_command do
            argument :message, {}

            options do |parser, config|
              config.modification = :none
              parser.on('--modification=MODIFICATION') do |value|
                config.modification = value.intern
              end
            end

            workflow do |arguments, options|
              task(name_for(:task)) do
                step(name_for(:step)) do
                  shell :lines, %(
                    echo original: #{arguments.message}
                    echo modified: #{modified}
                  )
                end
              end
            end

            def execute(arguments, options)
              @message = arguments.message
              @options = options
              super
            end

            def modified
              case @options.modification
              when :none
                @message
              when :upper
                @message.upcase
              end
            end

            def name_for(component)
              "The #{component.to_s.capitalize}"
            end
          end
        }

        it 'correctly resolves Command methods' do
          simulate('*' => 'yes')

          expect { simulate { command.run(['A message', '--modification=upper']) } }.to show %(
            # Command Workflow

            ## The Task

              Steps...

              - [ ] The Step

              Continue?:
              yes, no, skip, step or preview?\s\s
              - [ ] The Step

                → echo original: A message
                  ⫶ original: A message

                → echo modified: A MESSAGE
                  ⫶ modified: A MESSAGE
          )
        end
      end
    end
  end
end
