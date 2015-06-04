# encoding: utf-8
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'new_relic/crepe/version'

Gem::Specification.new do |s|
  s.name          = 'new_relic-crepe'
  s.version       = NewRelic::Crepe::VERSION
  s.authors       = ['David Celis']
  s.email         = ['me@davidcel.is']
  s.description   = 'New Relic Instrumentation for Crepe, the thin API stack.'
  s.summary       = 'New Relic Instrumentation for Crepe, the thin API stack.'
  s.homepage      = 'https://github.com/davidcelis/new_relic-crepe'
  s.license       = 'MIT'

  s.require_paths = ['lib']

  s.files         = Dir['lib/**/*.rb']
  s.test_files    = Dir['spec/**/*.rb']

  # We can only support the same Ruby versions as Crepe itself, after all.
  s.required_ruby_version = '>= 2.1.0'

  s.add_dependency 'newrelic_rpm', '>= 3.9.2'
  s.add_dependency 'crepe', '>= 0.0.1.pre'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rack-test', '~> 0.6'
end
