# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bbva/version'

Gem::Specification.new do |spec|
  spec.name          = "bbva"
  spec.version       = BBVA::VERSION
  spec.authors       = ["Javier Cuevas"]
  spec.email         = ["javi@diacode.com"]
  spec.description   = %q{Retrieves balance and transactions for BBVA bank accounts using the same API that the offical mobile app uses.}
  spec.summary       = %q{Command line tool to retrieve BBVA bank accounts balance and transactions}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['bbva']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency 'thor'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'
  spec.add_dependency 'faraday-cookie_jar'
  spec.add_dependency 'byebug'
  spec.add_dependency 'multi_xml'
end
