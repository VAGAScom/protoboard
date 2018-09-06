# Protoboard

[![Build Status](https://travis-ci.org/VAGAScom/protoboard.svg?branch=master)](https://travis-ci.org/VAGAScom/protoboard)
[![Maintainability](https://api.codeclimate.com/v1/badges/39e7c6f1f5f57b8555ed/maintainability)](https://codeclimate.com/github/VAGAScom/protoboard/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/39e7c6f1f5f57b8555ed/test_coverage)](https://codeclimate.com/github/VAGAScom/protoboard/test_coverage)\
Protoboard abstracts the way you use Circuit Breaker allowing you to easily use it with any Ruby Object, under the hood it uses the gem [stoplight](https://github.com/orgsync/stoplight) to create the circuits.


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

The usage is really simple, just include `Protoboard::CircuitBreaker` and register your circuit.

```ruby
class MyFooService
  include Protoboard::CircuitBreaker

  register_circuits [:some_method],
    options: {
      service: 'my_cool_service',
      open_after: 2,
      cool_off_after: 3
    }

  def some_method
    # Something that can break
  end
end
```

You can also define a fallback and callbacks for the circuit.

```ruby
class MyFooService
  include Protoboard::CircuitBreaker

  register_circuits [:some_method],
    fallback: -> (error) { 'Do Something' }
    on_before: [->(ce) { Something.notify("Circuit #{ce.circuit.name}") }, ->(_) {}],
    on_after: [->(ce) { Something.notify("It fails with #{ce.error}") if ce.fail? }],
    options: {
      service: 'my_cool_service',
      open_after: 2,
      cool_off_after: 3
    }
  def some_method
    # Something that can break
  end
end
```

Also if you want to add more than one method in the same class and customize the circuit name:

```ruby
class MyFooService
  include Protoboard::CircuitBreaker

  register_circuits({ some_method: 'my_custom_name', other_method: 'my_other_custom_name' },
    options: {
      service: 'my_service_name',
      open_after: 2,
      cool_off_after: 3
    })
  def some_method
    'OK'
  end
end
```

And you can add singleton methods to be wrapped by a circuit:

```ruby
class MyFooService
  include Protoboard::CircuitBreaker

  register_circuits [:some_method, :some_singleton_method],
    singleton_methods: [:some_singleton_method],
    options: {
      service: 'my_cool_service',
      open_after: 2,
      cool_off_after: 3
    }

  def self.some_singleton_method
    # Something that can break
  end

  def some_method
    # Something that can break
  end
end
```

### Callbacks

Any callback should receive one argument that it will be an instance of `CircuitExecution` class, that object will respond to the following methods:

* `state` returns the current state of the circuit execution (`:not_started`, `:success` or `:fail`)
* `value` returns the result value of the circuit execution, if the circuit fail the value will be `nil`.
* `error` returns the error raised when the circuit fail, it will be `nil` if no error occurred
* `circuit` returns a circuit instance which has the options configured in `register_circuits` (`name`, `service`, `open_after` and `cool_off_after`)
* `fail?` returns `true` if the execution failed

P.S: In before calbacks the state will always be `:not_started` and in after callbacks the state can be either `:fail` or `:success`

### Check Services and Circuits Status

If you want to check the services and circuits registered in Protoboard you can use `Protoboard::CircuitBreaker.services_healthcheck`, it will return a hash with the status of all circuits:

```ruby
{
  'services' => {
    'my_service_name' => {
      'circuits' => {
        'some_namespace/my_service_name/SomeClass#some_method' => 'OK',
        'some_namespace/my_custom_name' => 'NOT_OK'
      }
    }
  }
}
```

PS: You can also disable the project namespace to be shown in `Protoboard::CircuitBreaker.services_healthcheck` passing the option `with_namespace: false`


## Configuration

In configuration you can customize the adapter options and set callbacks and configurations for all the Protoboard Circuits:

```ruby

Protoboard.configure do |config|
  config.adapter = Protoboard::Adapters::StoplightAdapter
  config.namespace = 'Foo'

  config.adapter.configure do |adapter|
    adapter.data_store = :redis # Default is :memory 
    adapter.redis_host = 'localhost'
    adapter.redis_port = 1234
  end
  
  #Global callbacks
  config.callbacks.before = [->(_) {}]
  config.callbacks.after = [MyCallableObject.new, ->(_) {}]
end

```

The available options are:

* `adapter =` Sets the adapter, `Protoboard::Adapters::StoplightAdapter` is the default
* `namespace =` It's used to name the circuit avoiding naming colision with other projects
* `callbacks.before =` Receives an array of callables, lambdas, procs or any object that responds to `call` and receives one argument. It will be called before each circuit execution.
* `callbacks.after =` Receives an array of callables, lambdas, procs or any object that responds to `call` and receives one argument. It will be called after each circuit execution.

### StoplightAdapter Options

* `datastore =` Sets the datastore(:redis or :memory). The default option is :memory
* `redis_host=` Sets the redis host
* `redis_port=` Sets the redis port

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/VAGAScom/protoboard.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
