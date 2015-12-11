module WIP
  module Runner
    module Renderer
      def asset(path)
        File.read(asset_path(path))
      end

      def asset_path(path)
        return File.expand_path(path) if File.exist?(path)

        paths = WIP::Runner::CLI.assets
        paths.each do |base|
          file = File.join("#{base}/#{path}")
          return file if File.exist?(file)
        end

        raise WIP::Runner::InvalidArgument,
          "#{path} not found in:\n#{paths.map { |base| "    - #{base}" }.join("\n")}"
      end

      # TODO: allow handler configuration/option
      def render(content, context = {})
        content = path?(content) ? asset(content) : content
        handler(:ERB, content).render(Context.for(context))
      end

      private

      def path?(content)
        (content.match(/\n/) == nil) && (content.match(/^.+\.[a-z]+$/) != nil)
      end

      def handler(key, content)
        Handlers::const_get(key).new(content)
      end
    end
  end
end

Dir[File.expand_path('../renderer/*.rb', __FILE__)].each { |f| require(f) }
