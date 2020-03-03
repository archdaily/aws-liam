# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'liam/version'

Gem::Specification.new do |spec|
  spec.name          = 'aws-liam'
  spec.version       = Liam::VERSION
  spec.authors       = ['alexismansilla', 'sebastian-palma', 'luctus']
  spec.email         = ['alexis.mansilla04@gmail.com', 'sebastianpalma@protonmail.com', 'luctus@gmail.com']
  spec.summary       = 'AWS SQS+SNS middleware integration between Ruby microservices'
  spec.description   = 'Improved communication between our (Ruby on Rails) apps with AWS SNS - SQS'
  spec.homepage      = 'http://github.com/archdaily/aws-liam'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.require_paths = ['lib']
  spec.add_dependency 'aws-sdk-sns', '~> 1.21'
  spec.add_dependency 'aws-sdk-sqs', '~> 1.23', '>= 1.23.1'
  spec.add_development_dependency 'bundler', '~> 2.1.4'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'webmock', '~> 3.7.6'
end
