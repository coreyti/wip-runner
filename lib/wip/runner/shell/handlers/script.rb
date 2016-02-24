require 'expect'
require 'open3'

module WIP
  module Runner
    module Shell
      module Handlers
        class Script < Base
          attr_reader :prompts

          def initialize(*)
            @name    = 'script'
            @args    = []
            @prompts = []
            super
          end

          def execute(ui, env, &block)
            prompts.empty? ? simplex!(ui, env, &block) : complex!(ui, env, &block)
          end

          def name(value)
            @name = value
          end

          def args(array)
            @args = array
          end

          def prompt(term, options = {})
            @prompts << [term, options] # Prompt.new(...)
          end

          private

          def arguments
            ([@name] + @args).join(' ')
          end

          def simplex!(ui, env, &block)
            Open3.popen2e(env, "#{executable} #{arguments}") do |stdin, stdoe, thread|
              while line = stdoe.gets
                @output.puts(line)
                block.call(line)
              end

              thread.value
            end
          end

          def complex!(ui, env, &block)
            Open3.popen2e(env, "#{executable} #{arguments}") do |stdin, stdoe, thread|
              prompts.each do |term, options|
                stdoe.expect(term) do |result|
                  stdin.puts ui.ask(term) do |q|
                    options.each { |k, v| q.send(:"#{k}=", v) }
                  end
                  stdoe.gets
                end
              end

              while line = stdoe.gets
                @output.puts(line)
                block.call(line)
              end

              thread.value
            end
          end
        end
      end
    end
  end
end
