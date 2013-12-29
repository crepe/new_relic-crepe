# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
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

  s.files         = Dir['lib/**/*.rb']
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'newrelic_rpm'
  s.add_dependency 'crepe'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
end
