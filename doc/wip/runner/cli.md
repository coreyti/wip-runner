# Specification: `wip-runner` (CLI)

## Executed as `wip-runner`

Given no arguments, it writes writes help to `stderr`

```ruby
expect { `wip-runner` }
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

## Executed as `wip-runner --help`

Given only the `help` command, it writes writes help to `stderr`

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

## Executed as `wip-runner --help`

Given only the `--help` flag, it writes writes help to `stderr`

```ruby
expect { `wip-runner --help` }
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

## Executed as `wip-runner <bogus command>`

Given bogus command, it writes writes help to `stderr`

```ruby
expect { `wip-runner bogus` }
  .to write %(
    Invalid command: bogus

    Usage: wip-runner <command> [options]

    Commands:
        version                          Prints version information
        help                             Prints help messages

    Options:
        -h, --help                       Prints help messages
            --specification              Prints detailed specifications
  ), :to => :stderr
```
