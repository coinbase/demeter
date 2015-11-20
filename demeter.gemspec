# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'demeter/version'

Gem::Specification.new do |spec|
  spec.name          = 'demeter-cli'
  spec.version       = Demeter::VERSION
  spec.authors       = ['Saso Matejina', 'Jeremy Deininger']
  spec.email         = []
  spec.summary       = %q{A complete manager for AWS security groups}
  spec.description   = %q{A complete manager for AWS security groups}
  spec.homepage      = 'https://github.com/coinbase/demeter'
  spec.license       = 'MIT'
  spec.cert_chain  = ['certs/coinbase.pem']
  spec.signing_key = File.expand_path("~/.ssh/coinbase-gem-private_key.pem") if $0 =~ /gem\z/  

  spec.files         = `git ls-files`.split("\n")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.0.0'

  spec.add_dependency 'thor',           '~> 0.19'
  spec.add_dependency 'aws-sdk',        '~> 2.1'
  spec.add_dependency 'hashdiff',       '~> 0.2'
  spec.add_dependency 'bundler',        '~> 1.6'
  spec.add_dependency 'colorize',       '~> 0.7'
  spec.add_dependency 'terminal-table', '~> 1.5'
  spec.add_dependency 'dotenv',         '~> 2.0'

  spec.add_development_dependency 'rake',   '~> 10'
  spec.add_development_dependency 'rspec',  '~> 3.3'
  spec.add_development_dependency 'pry'
end
