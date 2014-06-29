# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require File.expand_path('../lib/vx/worker/version.rb', __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "vx-worker"
  spec.version       = Vx::Worker::VERSION
  spec.authors       = ["Dmitry Galinsky"]
  spec.email         = ["dima.exe@gmail.com"]
  spec.description   = %q{ ci worker }
  spec.summary       = %q{ ci worker }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'dotenv'
  spec.add_runtime_dependency 'vx-common',               "= 0.3.1"
  spec.add_runtime_dependency 'vx-message',              "= 0.6.1"
  spec.add_runtime_dependency 'vx-container_connector',  "= 0.5.3"
  spec.add_runtime_dependency 'vx-instrumentation',      '= 0.1.1'
  spec.add_runtime_dependency 'vx-consumer',             '= 0.1.8'

  spec.add_runtime_dependency 'hashr',                   '= 0.0.22'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
