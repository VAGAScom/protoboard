
# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'protoboard/version'

Gem::Specification.new do |spec|
  spec.name          = 'protoboard'
  spec.version       = Protoboard::VERSION
  spec.authors       = ['Carlos Atkinson', 'Kelly Bhering']
  spec.email         = ['carlos.atks@gmail.com', 'kellybhering@hotmail.com']

  spec.summary       = 'Protoboard abstracts the way you use Circuit Breaker allowing you to easily use it with any Ruby Object'
  spec.homepage = 'https://github.com/VAGAScom/protoboard'

  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  # else
  #   raise 'RubyGems 2.0 or newer is required to protect against ' \
  #     'public gem pushes.'
  # end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dry-configurable', '~> 0.7.0'
  spec.add_dependency 'stoplight', '~> 2.1.3'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'redis', '~> 3.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
end
