# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'performify/version'

Gem::Specification.new do |spec|
  spec.name          = "performify"
  spec.version       = Performify::VERSION
  spec.authors       = ["Sergey Tsvetkov"]
  spec.email         = ["sergey.a.tsvetkov@gmail.com"]

  spec.summary       = %q{
    Service classes that makes your life easier
  }

  spec.description   = %q{
    Performify helps you to define your app logic in separated and isolated service classes
    that is easy to use, test and maitain.
  }

  spec.homepage      = "https://github.com/kimrgrey/performify"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0.0"

  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.5"
end
