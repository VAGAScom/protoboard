# Protoboard

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/protoboard`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'protoboard'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install protoboard

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/protoboard.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).



# Configuration

```ruby
      Protoboard.configure do |config|
        config.adapter = Protoboard::Adapters::StoplightAdapter

        config.adapter.configure do |adapter|
          adapter.data_store = :redis
          adapter.redis_host = 'localhost'
          adapter.redis_port = 1234
        end
      end
``



--Global por circuit

[:some_method1, :some_method2, :some_method3 ]

register_circuits [:some_method, :some_method2, :some_method3],
                  options: {
                    service: 'my_cool_service',
                    timeout: 1,
                    open_after: 2,
                    cool_off_after: 3
                  },
                  on_before: [->{}, ->{}],
                  on_after: [->{}, ->{}]


-- Global por App
Protoboard.configure do |config|
  config.callbacks.configure |callback| do
    callback.before: [->{}, ->{}],
    callback.after: [->{}, ->{}]
  end
end
