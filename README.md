# DBug

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/d_bug`. To experiment with that code, run `bin/console` for an interactive prompt.

## Flow

FileObserver # captura as alterações e notifica a Queue

QueueObserver # recebe notificacao de file change e dispara o runner

CommandRunner # executa os testes e notifica a fila com o status

QueueObserver # recebe a notificacao de teste concluido e notifica via SerialDispatcher

SerialComm # recebe o evento e envia a comunicacao


# D-Bug CLI Brainstorm

# CLI
 -s --serial-port=
 -e --exclude=
 -o --only=

```
dbug -p /dev/tty.usbserial.x -w ./spec -x 'docker exec -web bundle exec rspec spec {}'
monitoring /home/dev/workspace/app-x/spec
file <filename> changed running suit...
<suit stdout here>
suit returned success, notifing bug!
suit returned failure, notifing bug!
```

```
dbug -p /dev/tty.usbserial.x -w ./spec -x 'docker exec -web bundle exec rspec spec {}'
monitoring /home/dev/workspace/app-x/spec
can't connect to bug in /dev/tty.usbserial.x check port/cable
running in stealth mode...
file <filename> changed running suit...
<suit stdout here>
suit returned success, running in steath mode nobody will be notified
suit returned failure, running in steath mode nobody will be notified
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'd_bug'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install d_bug

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/d_bug. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DBug project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/d_bug/blob/master/CODE_OF_CONDUCT.md).
