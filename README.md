# Castor

Castor is intended to help define third-party developer facing configurations for gems.

## Usage

The goal of Castor is to use it to define Gem configurations. As such you would probably do something like this:

```ruby
class MyGem
  def configure(&block)
    @config = Castor.configure do |config|
      config.def :name, :old_value
    end
    block.call(@config) if block
  end
end

gem = MyGem.new.configure do |config|
  config.name = :new_value
end
```

There are many ways to define config values.

### Basic use-case

Setting config nodes this way will not use validation in any way, but makes it easy to quickly define nodes

```ruby
config.def :name, :value
```

### Mass assignment

Self explanatory. As will the basic setter, this doesn't offer any validation.

```ruby
config.def_many(:name => :value, :other_name => 'toto')
```


### Adding validations

```ruby
config.def :validated_symbol do 
  type Symbol
  default :value
end

config.def :validated_range do
  value_in 1..50
  default 1
end
```

The config nodes `validated_symbol` and `validated_range` will now have validation.

`validated_symbol` will only be accepted if new value is a Symbol

`validated_range` will only accept values between 1 and 50

If the validation fails, an `InvalidValueError` will be thrown

### Lazy evaluations

```ruby
configuration = Castor.configure do |config|
  i = 0
  config.def :next_id, :lazy => lambda { i += 1 }

  config.def :time_now do
    type Time, Date
    default { Time.now }
  end

  config.def :some_name, "a value"
end

# You can always pass lambdas as values,
# they will be lazy-evaluated when called
configuration.some_name = lambda { "some other value" }

configuration.next_id
# => 1
configuration.next_id
# => 2
configuration.time_now
# => 2013-03-22 23:32:03 -0400

configuration.some_name
# => "some other value"
```

Castor will validate the return value and throw an `InvalidValueError` if it is invalid

```ruby
config.time_now = lambda { 3 }
config.time_now
#=> InvalidValueError
```

### Procs

Because Castor lazy-evals lambdas, if what you need is an actual proc, you'll have to enforce the type

```ruby
configuration = Castor.configure do |config|
  config.def :a_proc do
    type Proc
    default { :some_value }
  end
end

configuration.a_proc
# => #<Proc:0x007ffdda2edda0 ...
```

### Nested config

You can nest Castor configurations. Castor will not create setters for the intermediate node. A user could therefore not overwrite it by accident.

```ruby
configuration = Castor.configure do |config|
  config.nested_config :nested => true do |nested|
    nested.def :value, 5
  end

  config.other_nested Castor.configure{|nested|
    nested.def :other_value, "value"
  }
end

configuration.nested_config.value
# => 3

configuration.other_nested.other_value 
# => "other_value"

configuration.other_nested = 3
# => NoMethodError
```

### Going Meta

It's possible to use `#{node}!` method to get the `Castor::Configuration::Node` object. It's currently not very useful :(.

```ruby
config.time_now!
# => #<Castor::Configuration::Node:0x007ffdda363af0 ...
```

## Installation

Add this line to your application's Gemfile:

    gem 'castor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install castor

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
