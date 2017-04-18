# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carrierwave/flickr/version'

Gem::Specification.new do |spec|
  spec.name          = "carrierwave-flickr"
  spec.version       = Carrierwave::Flickr::VERSION
  spec.authors       = ["Dzmitry Kavalionak"]
  spec.email         = ["dzm.kov@gmail.com"]

  spec.summary       = %q{Save your image attachments in http://flickr.com/ using Carrierwave}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'carrierwave', '~> 1.0'
  spec.add_dependency 'flickraw', '~> 0.9'

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "3.6.0.beta2"
  spec.add_development_dependency "activerecord", '~> 5.0'
  spec.add_development_dependency "sqlite3", '~> 1.3'
  spec.add_development_dependency "pry", '~> 0.2.3'
end
