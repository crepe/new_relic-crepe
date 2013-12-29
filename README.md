# NewRelic::Crepe

New Relic Instrumentation for [Crêpe][crepe], the thin API stack.

## Installation

In your application's Gemfile:

```ruby
gem 'new_relic-crepe'
```

In your APIs:

```ruby
require 'new_relic-crepe'

class MyAPI < Crepe::API
  use NewRelic::Agent::Instrumentation::Crepe

  get do
    # Reported as 'GET /'
  end

  namespace :users do
    get do
      # Reported as 'GET /users'
    end
  end
end
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a Pull Request

[crepe]: https://github.com/stephencelis/crepe
