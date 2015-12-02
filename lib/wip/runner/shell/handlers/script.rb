require 'expect'
require 'open3'

module WIP
  module Runner
    module Shell
      module Handlers
        class Script < Base
          attr_reader :prompts

          def initialize(*)
            @prompts = []
            super
          end

          def description
            @description ||= "```\n#{@content}\n```"
            # @description ||= @content
          end

          def execute(io, env, &block)
            prompts.empty? ? simplex!(io, env, &block) : complex!(io, env, &block)
          end

          def prompt(term, options = {})
            @prompts << [term, options]      # Prompt.new(...)
          end

          private

          def simplex!(io, env, &block)
            Open3.popen2e(env, executable) do |stdin, stdoe, thread|
              while line = stdoe.gets
                block.call(line)
              end

              thread.value
            end
          end

          def complex!(io, env, &block)
            Open3.popen2e(env, executable) do |stdin, stdoe, thread|
              prompts.each do |term, options|
                stdoe.expect(term) do |result|
                  stdin.puts io.ask(term) do |q|
                    options.each { |k, v| q.send(:"#{k}=", v) }
                  end
                  stdoe.gets
                end
              end

              while line = stdoe.gets
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
