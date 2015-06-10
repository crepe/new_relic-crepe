# NewRelic::Crepe

New Relic Instrumentation for [Crepe][crepe], the thin API stack.

## Installation

In your application's Gemfile:

```ruby
gem 'new_relic-crepe'
```

## Usage

That's it. Any class that subclasses `Crepe::API` will report in the correct transaction name, based on the request method and PATH. Additionally, query parameters will be sent to New Relic. If you have sensitive parameters, such as passwords or other pieces of personal information, it's recommended that you filter them by adding a NewRelic::Crepe specific configuration option to the agent:

```yaml
# config/newrelic.yml

common: &default_settings
  # Filter sensitive parameters (this is Crepe specific)
  filtered_params:
    - password
    - ccv
    - ssn
    # etc.
```

For more information on how to use New Relic, see their
[Ruby documentation][new_relic]

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a Pull Request

[crepe]: https://github.com/crepe/crepe
[new_relic]: http://docs.newrelic.com/docs/ruby/
