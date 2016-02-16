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
        def run(tasks, arguments, options)
          @arguments = arguments
          @options   = default(:options).merge(options)

          if format == :markdown
            @ui.out {
              @ui.indent do
                @tasks.each do |task|
                  evaluate(task)
                end
              end
            }
          else
            [tasks].flatten.each do |task|
              evaluate(task)
            end
          end
        end

        private

        def default(setting)
          @defaults ||= {
            :options => Options.new({
              :interactive => true,
              :format      => :text,
              :mode        => :execute
            }),
            :procs => {
              :execute => Proc.new { |line| @ui.out { @ui.say("> #{line.rstrip}") } },
              :silent  => Proc.new { |line| }
            }
          }

          @defaults[setting]
        end

        def x_evaluate(task)
          task.build(arguments, options)
          prefix = options.preview ? :preview : :execute

          # if task.heading?
          #   @io.say task.heading
          #   @io.newline
          # end

          section('Config') do
            # @ui.newline
            # @io.say '```'
            task.configs.each do |term, options, block|
              send(:"#{prefix}_config", term, options, &block)
            end
            # @io.say '```'
          end unless task.configs.empty?

          task.shells.each do |shell|
            section("Shell #{shell.type.downcase}") do
              send(:"#{prefix}_shell", shell)
              # @ui.newline
            end
          end

          # p task.children
          task.children.each do |child|
            section('Task') do
              evaluate(child)
            end
          end
        end

        def evaluate(task)
          task.build(arguments, options)

          if interactive? && ! task.configs.empty?
            task.configs.each do |term, options, block|
              evaluate_config(term, options, &block)
            end
            @ui.err { @ui.newline }
          end

          task.shells.each do |shell|
            section("Shell #{shell.type.downcase}") do
              send(:"#{mode}_shell", shell)
            end
          end

          task.steps.each do |step|
            evaluate(step)
          end
        end

        # ---

        # module Mode
        #   class Display
        #   end
        #
        #   class Execute
        #   end
        #
        #   class Silent < Execute
        #   end
        # end

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

        def display_shell(shell)
          @ui.out {
            @ui.say(shell.content)
          }
        end

        def execute_shell(shell)
          display_shell(shell) unless mode == :silent

          if approved?
            @ui.out {
              @ui.newline
              result = shell.execute(@ui, @env, &default(:procs)[mode])
              @ui.newline

              # TODO: raise instead of exit.
              exit 1 unless result.success?
            }
          else
            @ui.err {
              @ui.newline
              @ui.say('> (skipped)')
            }
          end
        end

        def silent_shell(shell)
          execute_shell(shell)
        end

        # ---

        # TODO: remove section concept (?) ... maybe move to Task DSL
        def section(heading, &block)
          if format == :markdown
            @ui.out {
              @ui.say("- [ ] #{heading}...")
              @ui.indent(&block)
            }
          else
            @ui.err {
              # @ui.indent do
              # @ui.say("#{heading}...")
              yield
              @ui.newline
              # end
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

        def interactive?
          options.interactive
        end

        def format
          options.format
        end

        def mode
          options.mode
        end
      end
    end
  end
end
