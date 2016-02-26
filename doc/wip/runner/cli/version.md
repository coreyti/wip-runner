# Documentation for `wip-runner version`

## Executed as `wip-runner version`

It writes writes version information to `stdout`

```ruby
expect { `wip-runner version` }
  .to write 'wip-runner version 0.4.1', :to => :stdout
```
