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

  ## Files ##
  # spec.files         = `git ls-files -z`.split("\x0")
  # spec.files.reject! { |fn| fn.include? "readme" }

  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/}) unless RUBY_VERSION >= "2.2.0" #-> deprecated in Ruby 2.2.0
  # spec.require_paths = ["lib"]

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise "RubyGems 2.0 or newer is required to protect against " \
  #     "public gem pushes."
  # end
  #
  #
  spec.add_dependency 'aws-sdk-sns', '~> 1.21'
  spec.add_dependency 'aws-sdk-sqs', '~> 1.23', '>= 1.23.1'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency 'rubocop', '~> 0.62'
end
