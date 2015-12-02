require 'open3'

module WIP
  module Runner
    module Shell
      class Runner
        attr_reader :arguments, :options

        def initialize(io, tasks, env = {})
          @io    = io
          @tasks = tasks
          @env   = env
          @io.indent_size = 2
        end

        def run(arguments, options)
          @arguments = arguments
          @options   = options

          @io.indent do
            @tasks.each do |task|
              evaluate(task)
            end
          end
        end

        private

        def evaluate(task)
          task.build(arguments, options)
          prefix = options.preview ? :preview : :execute

          section('Config') do
            # @io.newline
            # @io.say '```'
            task.configs.each do |term, options|
              send(:"#{prefix}_config", term, options)
            end
            # @io.say '```'
          end unless task.configs.empty?

          task.shells.each do |shell|
            section("Shell #{shell.type.downcase}") do
              @io.newline
              send(:"#{prefix}_shell", shell)
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
          answer = @io.ask("- #{query}: ") do |q|
            q.default  = (options[:default] || ENV[term]) unless options[:password]
            q.echo     = false  if options[:password]
            q.validate = /^.+$/ if options[:required]
          end
          @env[term] = answer unless answer.empty?
          @env[term] ||= ENV[term]
        end

        def execute_shell(shell)
          preview_shell(shell)

          if approved?
            @io.newline
            result = shell.execute(@io, @env) do |line|
              # @io.say "> `#{line.rstrip}`<br>"
              @io.say "> #{line.rstrip}"
              # puts "#{@io.indentation}> `#{line.rstrip}`  "
              # @io.instance_variable_get(:@output).puts "> `#{line.rstrip}`  "

              # @io.send((action || :say), line)
            end
            @io.newline

            # TODO: raise instead of exit.
            exit 1 unless result.success?
          else
            @io.newline
            @io.say '> (skipped)'
          end
        end

        def preview_config(term, options = {})
          message = options[:required] ? "#{term} (*)" : term
          @io.say "- #{message}"
        end

        def preview_shell(shell)
          @io.say shell.description
        end

        # ---

        def section(heading, &block)
          @io.say "- [ ] #{heading}..."
          @io.indent(&block)
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
