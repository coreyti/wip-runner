require 'open3'

module WIP
  module Runner
    module Shell
      class Runner
        attr_reader :arguments, :options

        # TODO: enforce env keys as String OR Symbol
        def initialize(ui, env = {})
          @ui  = ui
          @env = env
        end

        # TODO: custom proc for UI???
        def run(tasks, arguments, options, &block)
          @arguments = arguments
          @options   = default(:options).merge(options)

          if format == :markdown
            raise 'TODO'
            # @ui.out {
            #   @ui.indent do
            #     [tasks].flatted.each do |task|
            #       evaluate(task)
            #     end
            #   end
            # }
          else
            [tasks].flatten.each do |task|
              evaluate(task, &block)
            end
          end
        end

        private

        def default(setting)
          @defaults ||= {
            :options => Options.new({
              :echo        => true,
              :format      => :text,
              :interactive => true,
              :mode        => :execute
            }),
            :procs => {
              :execute => Proc.new { |line| @ui.out { @ui.say("> #{line.rstrip}") } },
              :silent  => Proc.new { |line| }
            }
          }

          @defaults[setting]
        end

        def evaluate(task, &block)
          task.build(arguments, options)

          section(task.heading) do
            if interactive? && ! task.configs.empty?
              task.configs.each do |term, options, b|
                evaluate_config(term, options, &b)
              end
              @ui.err { @ui.newline }
            end

            task.shells.each do |shell|
              send(:"#{mode}_shell", shell, &block)
            end

            task.steps.each do |step|
              evaluate(step, &block)
            end
          end
        end

        def default_config(term, options = {})
          options[:default] || @env[term] || ENV[term]
        end

        def evaluate_config(term, options = {})
          query  = options[:required] ? "#{term} (*)" : term
          answer = @ui.err do
            @ui.ask("- #{query}: ") do |q|
              q.default  = default_config(term, options) unless options[:password]
              q.echo     = false  if options[:password]
              q.validate = /^.+$/ if options[:required]
            end
          end

          if block_given?
            yield answer
          else
            @env[term] = answer unless answer.empty?
            @env[term] ||= ENV[term]
          end
        end

        def display_shell(shell, &block)
          if block_given?
            block.call(shell.content)
          else
            @ui.out {
              @ui.say(shell.content)
            }
          end
        end

        def execute_shell(shell, &block)
          display_shell(shell) unless (mode == :silent) || ! echo?

          @ui.out {
            if approved?
              if block_given?
                result = shell.execute(@ui, @env, &block)
              else
                @ui.newline
                result = shell.execute(@ui, @env, &default(:procs)[mode])
                @ui.newline
              end

              # TODO: raise instead of exit.
              exit 1 unless result.success?
            else
              if block_given?
                block.call('> (skipped)')
              else
                @ui.newline
                @ui.say('> (skipped)')
              end
            end
          }
        end

        def silent_shell(shell)
          execute_shell(shell)
        end

        # ---

        def section(heading, &block)
          if format == :markdown
            @ui.out {
              @ui.say("- [ ] #{heading}")
              @ui.indent(&block)
            }
          else
            @ui.err {
              if heading
                @ui.say(heading)
                @ui.newline
              end
              yield
              @ui.newline
            }
          end
        end

        # ---

        def approved?
          return true unless @options.stepwise

          # case choice
          # when 'yes'
          # end
        end

        def echo?
          !! options.echo
        end

        def format
          options.format
        end

        def interactive?
          options.interactive
        end

        def mode
          options.mode
        end
      end
    end
  end
end
