

``` bash
bosh-tools generate-fly-exec -p path/to/pipeline.yml -j job-name -t task-name

bosh-tools fly exec path/to/task.yml
bosh-tools fly exec path/to/task.yml path/to/another-task.yml
bosh-tools fly exec path/to/pipeline.yml:job-name -t task-1 -t task-2
bosh-tools fly exec path/to/pipeline.yml:job-name -j pipeline-name/job-name -i bosh-src=..
```

# TODO

## wip-runner

- add better handling of shell execution failure and stderr writing. e.g., when
  `fly -t production get-pipeline -p bosh` fails due to auth error.
- respect pipes:
  - <http://www.jstorimer.com/blogs/workingwithcode/7766125-writing-ruby-scripts-that-respect-pipelines>
  - <http://blog.honeybadger.io/capturing-stdout-stderr-from-shell-commands-via-ruby/>
- allow for "sections" within tasks, with formatting options
  ...that is, provide a clear way to distinguish setup input/output from
  script rendering output and execution output.
- run modes:
  - execute
  - preview/dry-run (would prompt, but not execute)
  - non-interactive (no prompts, can be combined with execute or preview)
- figure out why "preview" mode works fine, while "execute" mode does not,
  when given a script with wrapped lines, as such:
  ```
  fly exec \
    -t production
  ```
- rename config to prompt in Tasks ???

## old ???

``` ruby
$ wip-runner x --format=markdown
$ wip-runner x --log=out.md       # log format determined by extension

@formatter = Formatter::Markdown.new(@io)

def item(text)
  formatter.item(text)
end

class Formatter::Markdown
  def item(text, check = true)
    @io.say check ? "- [ ] #{text}" : "- #{text}"
  end
end

class Formatter::Plain
class Formatter::Color
class Formatter::HTML
class Formatter::JSON
```

## bosh-tools

- multiple taskfiles
- 'Add debug details to the generated script'
- non-interactive (don't prompt, use defaults, don't execute)

``` bash
bosh-tools fly exec path/to/task-1.yml path/to/task-2.yml
bosh-tools fly exec path/to/pipeline.yml:job-name
bosh-tools fly exec path/to/pipeline.yml:job-name:task-1
bosh-tools fly exec path/to/pipeline.yml:job-name:task-1,task-2

bosh-tools fly exec path/to/pipeline.yml:job-name -t task-1 -t task-2
```

# The following should:
# - prompt for configs (`--exec`)
# - write the generated script to STDOUT
# - write the script execution output to STDERR
``` bash
RUBY_VERSION=2.1.7
bosh-tools fly exec bosh-ci/tasks/test-unit.yml \
  -t production --exec > script.sh
```

``` ruby
module Bosh
  module Tools
    module Commands
      class Fly::Exec < Bosh::Tools::Command
        argument :taskfile

        workflow do |arguments, options|
          helpers << Bosh::Tools::Helpers::EnvironmentHelper
          helpers << Bosh::Tools::Helpers::FlyHelpers

          task 'Provide values for the following' do
            config :RUBY_VERSION
          end

          task do
            shell :script, %(
              #!/usr/bin/env bash
              #
              # Generated at <%= helpers.timestamp %> using:
              # '<%= helpers.command %>'
              <%
                lines = [].tap do |a|
                  a << 'fly ${target} execute -c ${TASKFILE}'
                  a << helpers.switches
                  a << helpers.inputs
                  a << helpers.outputs
                  a << helpers.tags
                end
              %>
              set -e

              : ${TASKFILE:=<%= arguments.taskfile %>}
              : ${TEMP_FOLDER:=$(mktemp -d -t fly-exec)}
              : ${CONCOURSE_TARGET:=<%= options.target %>}
              <% params[:env].each do |key, value| %>
              export <%= key %>=${<%= key %>:=<%= value %>}<% end %>

              [[ "$CONCOURSE_TARGET" != "" ]] && target="-t ${CONCOURSE_TARGET}" || target=""

              <%= helpers.wrap(lines) %>

              echo "Task outputs (${TEMP_FOLDER}):"
              ls -l ${TEMP_FOLDER}
            )
          end
        end

        def initialize(ui)
          super
          # ???
          # configuration must be reset after execution of this Command
          @ui.configure({
            :prompt  => :stderr,
            :preview => :stdout,
            :execute => :stderr
          })
        end
      end
    end
  end
end  
```    


## Old (?)

``` bash
bosh-tools fly exec bosh-ci/tasks/test-unit.yml -t production -j bosh/test-1.9
bosh-tools fly exec bosh-ci/tasks/test-unit.yml -t production -j bosh/test-1.9 -i bosh-src=../bosh

RUBY_VERSION=1.9.3 bosh-tools fly exec bosh-ci/tasks/test-unit.yml -t production -j bosh/test-1.9
bosh-tools fly exec ci/pipeline.yml unit-1.9
#   > select a task:
#     [*] all
#     [1] test
#   > provide values for the following...
#   > RUBY_VERSION

# - OR -

bosh-tools fly exec ci/tasks/run-unit.yml
#   > provide values for the following...
#     RUBY_VERSION:

bosh-tools fly exec ci/tasks/run-unit.yml -p ci/pipeline.yml --interactive
#   > select a pipeline job:
#     [1] unit-1.9
#     [2] unit-2.1
#     2
#
#   > provide values for the following...
#     RUBY_VERSION [2.1.7]:
#
#     ...
```
