# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'castor/version'

Gem::Specification.new do |gem|
  gem.name          = "castor"
  gem.version       = Castor::VERSION
  gem.authors       = ["Guillaume Malette"]
  gem.email         = ["gmalette@gmail.com"]
  gem.description   = %q{Castor is a configuration management gem. It can help write configuration apis for other gems}
  gem.summary       = %q{Castor is a configuration management gem.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "pry"
  gem.add_development_dependency "rspec"
end
