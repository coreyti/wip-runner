require 'open3'

module WIP
  module Runner
    module Shell
      class Runner
        attr_reader :arguments, :options

        def initialize(ui, tasks, env = {}, &block)
          @ui    = ui
          @tasks = [tasks].flatten
          @env   = env
          @proc  = block || default_proc
        end

        def run(arguments, options)
          @arguments = arguments
          @options   = options

          if markdown?
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

        def default_proc
          Proc.new { |line| @ui.say(:out, "> #{line.rstrip}") }
        end

        def evaluate(task)
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

        # ---

        # class Execute
        # end
        #
        # class Preview
        # end

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
          preview_shell(shell) unless options.silent

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

        # TODO: determine where preview_config should still prompt.
        def preview_config(term, options = {})
          message = options[:required] ? "#{term} (*)" : term
          @ui.say(:err, "- #{message}")
        end

        def preview_shell(shell)
          @ui.say(:out, shell.description)
        end

        # ---

        def section(heading, &block)
          if markdown?
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

        def format
          @options.format ? @options.format.intern : :text
        end

        def markdown?
          format == :markdown
        end

        # $ wip-runner x --format=markdown
        # $ wip-runner x --log=out.md       # log format determined by extension
        #
        # @formatter = Formatter::Markdown.new(@io)
        #
        # def item(text)
        #   formatter.item(text)
        # end
        #
        # class Formatter::Markdown
        #   def item(text, check = true)
        #     @io.say check ? "- [ ] #{text}" : "- #{text}"
        #   end
        # end
        #
        # class Formatter::Plain
        # class Formatter::Color
        # class Formatter::HTML
        # class Formatter::JSON

        # ---

        def approved?
          return true unless @options.stepwise

          # case choice
          # when 'yes'
          # end
        end
      end
    end
  end
end
