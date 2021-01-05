lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'performify/version'

Gem::Specification.new do |spec|
  spec.name = "performify"
  spec.version = Performify::VERSION
  spec.authors = ["Sergey Tsvetkov"]
  spec.email = ["sergey.a.tsvetkov@gmail.com"]

  spec.summary = "Service classes that makes your life easier"

  spec.description = "Performify helps you to define your app logic in separated and isolated \
                      service classes that is easy to use, test and maitain."

  spec.homepage = "https://github.com/kimrgrey/performify"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 4.0"
  spec.add_dependency "dry-schema", "~> 1.5"

  spec.add_development_dependency "sqlite3", "~> 1.4"
  spec.add_development_dependency "bundler", "~> 2.2.4"
  spec.add_development_dependency "rake", "~> 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0.48"
  spec.add_development_dependency "byebug", "~> 9.0.6"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.4.1"
end
