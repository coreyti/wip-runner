`→ bosh-tools fly exec --specification`

# Specification for `bosh-tools fly exec`

```
Usage: bosh-tools fly exec <arguments> [options]

Arguments:
    tasks                            Task(s) to execute.
                                     Tasks may be provide as:
                                       - `path/to/task.yml`
                                       - `path/to/pipeline.yml:job-name`
                                     [multiple]

Options:
    -t TARGET                        Concourse target name or URL
    -c PIPELINE/JOB                  A job from which to pull config
    -j PIPELINE/JOB                  A job from which to pull inputs
    -i NAME=PATH                     An input to provide to the task (multiple)
    -p                               Run the task with full privileges
    -x                               Skip uploading .gitignore'd paths
        --tag VALUE                  A tag for the specific environment (multiple)
        --execute                    Execute the generated script
    -h, --help                       Prints help messages
```

## Executed as `bosh-tools fly exec <path/to/task.yml>`

It ...

```ruby
expect { `bosh-tools fly exec doc/assets/task.yml` }
  .to write
  %(
    prompts...
  ), :to => :stderr,
  %(
    output...
  ), :to => :stdout
```
