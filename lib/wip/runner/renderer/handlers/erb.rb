require 'erb'

module WIP::Runner::Renderer
  class Handlers::ERB
    def initialize(template)
      @template = clean(template)
    end

    def render(context)
      ::ERB.new(@template).result(context)
    end

    private

    def clean(string)
      return if string.nil?

      indent = (string.scan(/^[ \t]*(?=\S)/).min || '').size
      string.gsub(/^[ \t]{#{indent}}/, '').strip
    end
  end
end
