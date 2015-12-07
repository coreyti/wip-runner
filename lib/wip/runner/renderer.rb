module WIP
  module Runner
    module Renderer
      # TODO: allow handler configuration/option
      def render(content, context = {})
        content = path?(content) ? template(content) : content
        handler(:ERB, content).render(Context.for(context))
      end

      def template(path)
        base_paths = WIP::Runner::CLI.templates
        base_paths.each do |base|
          file = File.join("#{base}/#{path}")
          return File.read(file) if File.exist?(file)
        end

        raise WIP::Runner::InvalidArgument, "#{path} not found in:\n#{base_paths.map { |base| "    - #{base}" }.join("\n")}"
      end

      private

      def path?(content)
        File.extname(content).match(/\.[a-z]+$/)
      end

      def handler(key, content)
        Handlers::const_get(key).new(content)
      end
    end
  end
end

Dir[File.expand_path('../renderer/*.rb', __FILE__)].each { |f| require(f) }
