# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest-check/version'

Gem::Specification.new do |gem|
  gem.name          = "minitest-check"
  gem.version       = Minitest::Check::VERSION
  gem.authors       = ["Andrew O'Brien"]
  gem.email         = ["obrien.andrew@gmail.com"]
  gem.description   = %q{Generative testing for Minitest.}
  gem.summary       = %q{Testing with fixed data causes false negatives. Testing with random values leads to spaghetti. Run tests across entire domains with this library.}
  gem.homepage      = "https://github.com/AndrewO/minitest-check"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.license = 'MIT'
end
