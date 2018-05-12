# Specification: `wip-runner help`

## Executed as `wip-runner help`

It writes *overall* help text for `wip-runner`, to `stderr`.

```ruby
expect { `wip-runner help` }
  .to write %(
    Usage: wip-runner <command> [options]

    Commands:
        version                          Prints version information
        help                             Prints help messages

    Options:
        -h, --help                       Prints help messages
            --specification              Prints detailed specifications
  ), :to => :stderr
```

## Executed as `wip-runner help <command>`, given a valid command

It writes *command* help text, to `stderr`.

```ruby
expect { `wip-runner help version` }
  .to write %(
    Usage: wip-runner version [options]

    Options:
        -h, --help                       Prints help messages
            --specification              Prints detailed specifications
  ), :to => :stderr
```

## Executed as `wip-runner help <command>`, given a bogus command

It writes *general* help text, to `stderr`.

```ruby
expect { `wip-runner help bogus` }
  .to write %(
    Invalid command: bogus

    Usage: wip-runner help <arguments> [options]

    Arguments:
        command                          Command

    Options:
        -h, --help                       Prints help messages
            --specification              Prints detailed specifications
  ), :to => :stderr
```
