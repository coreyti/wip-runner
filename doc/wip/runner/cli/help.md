# Documentation for `wip-runner help`

## Executed as `wip-runner help`

It writes *overall* help text for `wip-runner`, to `stdout`.

```ruby
expect { `wip-runner help` }
  .to write %(
    Usage: wip-runner <command> [options]

    Commands:
        help                             Prints help messages
        version                          Prints version information

    Options:
        -h, --help                       Prints help messages
  ), :to => :stdout
```

## Executed as `wip-runner help <command>`, given a valid command

It writes *command* help text, to `stdout`.

```ruby
expect { `wip-runner help version` }
  .to write %(
    Usage: wip-runner version [options]

    Options:
        -h, --help                       Prints help messages
  ), :to => :stdout
```

## Executed as `wip-runner help <command>`, given a bogus command

It writes *general* help text, to `stdout`.

```ruby
expect { `wip-runner help bogus` }
  .to write %(
    Invalid command: bogus

    Usage: wip-runner help <arguments> [options]

    Arguments:
        command                          Command name

    Options:
        -h, --help                       Prints help messages
  ), :to => :stdout
```