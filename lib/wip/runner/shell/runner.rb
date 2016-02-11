require 'open3'

module WIP
  module Runner
    module Shell
      class Runner
        attr_reader :arguments, :options

        # TODO: move env and/or block to #run ???
        # TODO: enforce env keys as String OR Symbol
        def initialize(ui, tasks, env = {}, &block)
          @ui    = ui
          @tasks = [tasks].flatten
          @env   = env
          @proc  = block || default_proc
        end

        def run(arguments, options)
          @arguments = arguments
          @options   = default(:options).merge(options)

          if format == :markdown
            @ui.indent(:out) do
              @tasks.each do |task|
                evaluate(task)
              end
            end
          else
            @tasks.each do |task|
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
            })
          }

          @defaults[setting]
        end

        # :p
        def default_proc
          Proc.new { |line| @ui.say(:out, "> #{line.rstrip}") }
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
              # @ui.newline(:err)
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
              execute_config(term, options, &block)
            end
          end

          task.shells.each do |shell|
            section("Shell #{shell.type.downcase}") do
              send(:"#{mode}_shell", shell)
            end
          end

          # TODO: children tasks
        end

        # ---

        # module Mode
        #   class Execute
        #   end
        #
        #   class Display
        #   end
        # end

        def default_config(term, options = {})
        end

        def execute_config(term, options = {})
          query  = options[:required] ? "#{term} (*)" : term
          answer = @ui.ask(:err, "- #{query}: ") do |q|
            q.default  = (options[:default] || ENV[term]) unless options[:password]
            q.echo     = false  if options[:password]
            q.validate = /^.+$/ if options[:required]
          end

          if block_given?
            yield answer
          else
            @env[term] = answer unless answer.empty?
            @env[term] ||= ENV[term]
          end
        end

        def execute_shell(shell)
          display_shell(shell) # unless options.silent

          if approved?
            @ui.newline(:out)
            # result = shell.execute(@io, @env) do |line|
            #   # @io.say "> `#{line.rstrip}`<br>"
            #   @io.say "> #{line.rstrip}"
            #   # puts "#{@io.indentation}> `#{line.rstrip}`  "
            #   # @io.instance_variable_get(:@output).puts "> `#{line.rstrip}`  "
            #
            #   # @io.send((action || :say), line)
            # end
            result = shell.execute(@ui, @env, &@proc)
            @ui.newline(:out)

            # TODO: raise instead of exit.
            exit 1 unless result.success?
          else
            @ui.newline(:err)
            @ui.say(:err, '> (skipped)')
          end
        end

        def display_shell(shell)
          @ui.say(:out, shell.description)
        end

        # ---

        # TODO: remove section concept (?) ... maybe move to Task DSL
        def section(heading, &block)
          if format == :markdown
            @ui.say(:out, "- [ ] #{heading}...")
            @ui.indent(:out, &block)
          else
            # @io.indent do
              # @ui.say(:err, "#{heading}...")
              yield
              @ui.newline(:err)
            # end
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
