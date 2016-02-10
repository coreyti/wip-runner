require 'wip/runner/workflow/builder'
require 'wip/runner/workflow/builder/component'
require 'wip/runner/workflow/builder/workflow'
require 'wip/runner/workflow/builder/task'
require 'wip/runner/workflow/builder/step'
require 'wip/runner/workflow/runner'

module WIP
  module Runner
    module Workflow
      class Error      < WIP::Runner::Error; end
      class GuardError < Error; end
      class HaltSignal < Error; end

      def self.define(&block)
        command = (eval 'self', block.send(:binding))
        command.send(:include, InstanceMethods)

        command.class_exec do
          options do |parser, config|
            config.overview = false
            config.preview  = false

            parser.on('--overview', 'Prints workflow overview') do
              config.no_validate = true
              config.overview    = true
            end

            parser.on('--preview', 'Prints workflow preview') do
              config.preview = true
            end

            define_method(:builder) do
              @builder ||= Builder.new(self, &block)
            end
          end
        end
      end

      module InstanceMethods
        def execute(arguments, options)
          workflow = builder.build(arguments, options)
          runner   = Runner.new(@ui, workflow)
          runner.run(options)
        end
      end
    end
  end
end
