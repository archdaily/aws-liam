lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "liam/version"

Gem::Specification.new do |spec|
  spec.name          = "liam"
  spec.version       = Liam::VERSION
  spec.authors       = ["alexismansilla"]
  spec.email         = ["alexis.mansilla04@gmail.com"]

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "http://github.com/archdaily/liam"
  spec.license       = "MIT"
  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ["lib"]
  #
  spec.add_dependency 'aws-sdk-sns', '~> 1.21'
  spec.add_dependency 'aws-sdk-sqs', '~> 1.23', '>= 1.23.1'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'byebug', '~> 11.0', '>= 11.0.1'
  spec.add_development_dependency 'rubocop', '~> 0.62'
end
