require 'rouge'

module WIP
  module Runner
    class Command
      class Specification
        def initialize(command)
          @command = command
        end

        def read
          source    = File.read(command_docs)
          formatter = Rouge::Formatters::Terminal256.new(:theme => 'wip')
          lexer     = Rouge::Lexers::Markdown.new
          formatter.format(lexer.lex(source))
        end

        private

        def command_docs
          @command_docs ||= Dir["#{WIP::Runner::CLI.docs}/**/#{command_path}.md"].first
        end

        def command_path
          @command_path ||= begin
            @command.to_s.split('::').join('/').downcase
          end
        end

        class Theme < Rouge::Themes::MonokaiSublime
          name 'wip'

          style Generic::Heading, :fg => :whitish, :bold => true
          style Generic::Emph,    :fg => :whitish, :bold => true
        end
      end
    end
  end
end
