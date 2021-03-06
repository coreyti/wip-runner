require 'open3'
require 'yaml'

module WIP
  module Runner
    module Workflow
      class Runner
        def initialize(ui, workflow)
          @ui       = ui
          @workflow = workflow
        end

        def run(options)
          @options = options
          @context = []
          @env     = {}

          process_overview
          process_workflow unless @options.overview
        end

        private

        def stylize(text, style)
          stylize? ? @ui.out { @ui.color(text, style) } : text
        end

        def stylize?
          true
        end

        def process_overview
          @ui.out {
            @ui.newline
            @ui.indent do
              @ui.say "# #{stylize(@workflow.heading, :underline)}"

              unless @workflow.overview.nil?
                @ui.newline
                @ui.say @workflow.overview
              end

              unless @workflow.prologue.nil?
                @ui.newline
                @ui.say @workflow.prologue
              end
            end
          }
        end

        def process_workflow
          @context.push({ sources: [] })

          @ui.out {
            @ui.indent do
              process_configs unless @options.preview
              process_guards unless @options.preview

              @workflow.shells.each do |mode, content|
                process_shell(content, mode)
              end

              @workflow.tasks.each do |task|
                process_task(task)
              end
            end
          }

          @context.pop
        rescue GuardError, HaltSignal
          # no-op (execution already blocked)
        end

        def process_task(task, overview = true)
          process_block('##', task, overview, :underline) do
            if overview && ! (task.shells.empty? && task.steps.empty?)
              @ui.out {
                @ui.newline
                @ui.say 'Steps...'
              }
            end

            if @options.preview
              task.shells.each do |mode, content|
                process_shell(content, mode)
              end

              task.steps.each do |step|
                process_step(step)
              end
            else
              @ui.out {
                if overview
                  @options.preview = true
                  task.shells.each do |mode, content|
                    process_shell(content, mode)
                  end
                  @options.preview = false

                  task.steps.each do |step|
                      @ui.newline
                      @ui.say("- [ ] #{step.heading}")
                  end
                end

                @ui.newline
                @ui.err {
                  choice = @ui.choose('yes', 'no', 'skip', 'step', 'preview') do |menu|
                    menu.header = 'Continue?'
                    menu.flow   = :inline
                    menu.index  = :none
                  end

                  case choice
                  when 'yes'
                    proceed_with_task(task)
                  when 'no'
                    raise HaltSignal
                  when 'skip'
                    @ui.indent_level -= 1
                    return
                  when 'step'
                    @options.stepwise = true
                    task.shells.each do |mode, content|
                      process_shell(content, mode)
                    end

                    task.steps.each do |step|
                      process_step(step)
                    end
                    @options.stepwise = false
                  when 'preview'
                    @options.preview = true
                    task.shells.each do |mode, content|
                      process_shell(content, mode)
                    end
                    task.steps.each do |step|
                      process_step(step)
                    end
                    @options.preview = false

                    @ui.indent(-1) do
                      process_task(task, false)
                    end
                  end
                }
              }
            end
          end
        end

        def process_step(step, overview = true)
          process_block('- [ ]', step, overview) do
            if @options.preview
              step.shells.each do |mode, content|
                process_shell(content, mode)
              end
            else
              if @options.stepwise
                @options.preview = true
                step.shells.each do |content, mode|
                  process_shell(mode, content)
                end
                @options.preview = false

                @ui.err {
                  @ui.newline
                  choice = @ui.choose('yes', 'no', 'skip') do |menu|
                    menu.header = 'Continue?'
                    menu.flow   = :inline
                    menu.index  = :none
                  end

                  case choice
                  when 'yes'
                    proceed_with_step(step)
                  when 'no'
                    raise HaltSignal
                  when 'skip'
                    @ui.indent_level -= 1
                    return
                  end
                }
              else
                proceed_with_step(step)
              end
            end
          end
        end

        def process_configs
          unless @workflow.configs.empty?
            @ui.err {
              @ui.newline
              @ui.say "## #{stylize('Configuration', :underline)}"
              @ui.indent do
                @ui.newline
                @ui.say 'Please provide values for the following...'

                @workflow.configs.each do |key, options|
                  answer = @ui.ask("- #{key}: ") do |q|
                    q.default  = (options[:default] || ENV[key])
                    if options[:required]
                      # q.validate = Proc.new { |a| ! a.empty? }
                      q.validate = /^.+$/
                    end
                  end
                  @env[key] = answer unless answer.empty?
                end
              end
            }
          end
        end

        def process_guards
          @workflow.guards.each do |description, command, check|
            Open3.popen2e(@env, command) do |stdin, stdoe, wait_thread|
              status = wait_thread.value

              if status.success?
                expected = check
                unless expected.nil?
                  actual = stdoe.readlines.join.strip

                  if check.is_a?(Regexp)
                    operation = :=~
                  else
                    operation = :==
                    expected  = clean(expected)
                  end

                  unless actual.send(operation, expected)
                    guard_error(description, command, expected, actual)
                  end
                end
              else
                guard_error(description, command, nil, status.exitstatus)
              end
            end
          end
        end

        def process_block(prefix, component, overview = true, style = nil)
          @ui.out {
            @context.push({ sources: [] })

            if overview
              @ui.newline
              @ui.say("#{prefix} #{stylize(component.heading, style)}")
            end

            @ui.indent do
              unless component.prologue.nil?
                @ui.newline
                @ui.say component.prologue
              end if overview

              yield if block_given?
            end

            @context.pop
          }
        end

        def process_shell(content, mode)
          if @options.preview
            preview(content, mode) unless [:export, :source].include?(mode)
          else
            execute(content, mode)
          end
        end

        # ---

        def preview(content, mode)
          if mode == :script
            prefix = nil
            content = "```\n#{content}\n```"
          else
            prefix = '→ '
          end

          @ui.out {
            @ui.newline
            content.split("\n").each do |action|
              if action.empty?
                @ui.newline
              else
                @ui.say("#{prefix}#{stylize(action, :bold)}")
              end
            end
          }
        end

        # ---

        def execute(content, mode)
          case mode
          when :export
            @context.last[:sources] << load_export(content)
          when :source
            @context.last[:sources] << load_source(content)
          when :script
            execute_script(content)
          when :lines
            execute_lines(content)
          when :popen
            execute_popen(content)
          when :ticks
            execute_ticks(content)
          end
        end

        def load_export(content)
          command = content.gsub(/"/, '\"').gsub(/\$/, "\\$").lstrip
          command = %Q{bash -c "#{command}"}

          Open3.popen3(@env, command) do |stdin, stdout, stderr, wait_thread|
            status = wait_thread.value

            unless status.success?
              while line = stderr.gets
                error(line)
              end
              exit 1
            end

            YAML.load(clean(stdout.read)).map do |key, value|
              %Q(export #{key.upcase}="#{value}")
            end.join("\n").gsub(/"/, '\"').gsub(/\$/, "\\$")
          end
        end

        def load_source(content)
          content.gsub(/"/, '\"').gsub(/\$/, "\\$")
        end

        def execute_script(content)
          preview(content, :script)

          if @options.stepwise
            @ui.err {
              @ui.newline
              choice = @ui.choose('yes', 'no', 'skip') do |menu|
                menu.header = 'Continue?'
                menu.flow   = :inline
                menu.index  = :none
              end

              case choice
              when 'yes'
                @ui.newline
                proceed_with_script(content)
              when 'no'
                raise HaltSignal
              when 'skip'
                @ui.newline
              end
            }
          else
            proceed_with_script(content)
          end
        end

        def execute_lines(content)
          actions = content.split("\n")
          actions.each do |action|
            preview(action, :lines)

            if @options.stepwise
              @ui.err {
                @ui.newline
                choice = @ui.choose('yes', 'no', 'skip') do |menu|
                  menu.header = 'Continue?'
                  menu.flow   = :inline
                  menu.index  = :none
                end

                case choice
                when 'yes'
                  @ui.newline
                  proceed_with_line(action)
                  next
                when 'no'
                  raise HaltSignal
                when 'skip'
                  @ui.newline
                  next
                end
              }
            else
              proceed_with_line(action)
            end
          end
        end

        def execute_popen(content)
          lines = content.split("\n")
          lines.each do |line|
            preview(line, :popen)

            # TODO: stepwise
            command = line.gsub(/"/, '\"').gsub(/\$/, "\\$")
            command = (sources + [command]).join("\n")
            command = %Q{bash -c "#{command} 2>&1"}

            IO.popen(@env, command) do |pipe|
              @ui.out {
                @ui.indent do
                  pipe.each do |line|
                    @ui.say(line)
                  end
                end
              }
            end

            exit 1 unless $?.success?
          end
        end

        # def execute_ticks(content)
        #   content = content.gsub(/(\$[a-zA-Z0-9_]+)/) { |match| @env[match[1..-1]] }
        #   `#{content}`
        # end

        # ---

        def proceed_with_task(task)
          task.shells.each do |mode, content|
            process_shell(content, mode)
          end

          task.steps.each do |step|
            process_step(step)
          end
        end

        def proceed_with_step(step)
          step.shells.each do |mode, content|
            process_shell(content, mode)
          end
        end

        def proceed_with_script(script)
          script  = script.gsub(/"/, '\"').gsub(/\$/, "\\$")
          script  = (sources + [script]).join("\n")
          script  = %Q{bash -c "#{script}"}

          Open3.popen2e(@env, script) do |stdin, stdoe, wait_thread|
            status = wait_thread.value

            @ui.out {
              @ui.indent do
                while line = stdoe.gets
                  @ui.say("⫶ #{line}")
                end
              end

              exit 1 unless status.success?
            }
          end
        end

        def proceed_with_line(line)
          command = line.gsub(/"/, '\"').gsub(/\$/, "\\$")
          command = (sources + [command]).join("\n")
          command = %Q{bash -c "#{command}"}

          Open3.popen2e(@env, command) do |stdin, stdoe, wait_thread|
            status = wait_thread.value

            @ui.out {
              @ui.indent do
                while line = stdoe.gets
                  @ui.say("⫶ #{line}")
                end
              end

              exit 1 unless status.success?
            }
          end
        end

        # ---

        def sources
          @context.map { |c| c[:sources] }.flatten
        end

        def clean(string)
          return if string.nil?

          indent = (string.scan(/^[ \t]*(?=\S)/).min || '').size
          string.gsub(/^[ \t]{#{indent}}/, '').strip
        end

        def error(message)
          @ui.err { @ui.say stylize(message, :red) }
        end

        def guard_error(description, command, check, actual)
          case check
          when nil
            message = "Exit code was #{actual}"
          when String
            message = ['Output did not equal expected', check, actual]
          when Regexp
            message = ['Output did not match expected', check.inspect, actual]
          end

          @ui.err {
            @ui.newline
            error "Guard failed: '#{description}'"
            @ui.indent do
              error "→ #{command}"
            end

            if message.is_a?(Array)
              error message[0]

              @ui.newline
              @ui.say stylize('Expected:', :bold)
              @ui.indent do
                @ui.say message[1]
              end

              @ui.newline
              @ui.say stylize('Actual:', :bold)
              @ui.indent do
                @ui.say message[2]
              end
            else
              error message
            end
          }

          raise GuardError, message[0]
        end
      end
    end
  end
end
