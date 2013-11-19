# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

description = %q{
update DNS entries on cloud providers (Route 53 et al) based on your current external IP address. think like a dyndns updater. no-ip, et al.
}

Gem::Specification.new do |spec|
  spec.name          = "cloud-dyndns"
  spec.version       = CloudDyndns::VERSION
  spec.authors       = ["Nat Lownes"]
  spec.email         = ["nat.lownes@gmail.com"]
  spec.description   = description
  spec.summary       = description
  spec.homepage      = "https://github.com/natlownes/cloud-dyndns"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fog", '=1.18.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest-reporters"
  spec.add_development_dependency "minitest-matchers"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "minitest-spec-expect"
end
