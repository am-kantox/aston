# frozen_string_literal: true

require_relative 'lib/aston/version'

Gem::Specification.new do |spec|
  spec.name          = 'aston'
  spec.version       = Aston::VERSION
  spec.authors       = ['Aleksei Matiushkin']
  spec.email         = ['aleksei.matiushkin@kantox.com']

  spec.summary       = 'Helper to produce JSON hashes representing XML'
  spec.description   = 'Hash/JSON is not isomorphic to XML, unless produced with this library'
  spec.homepage      = 'https://github.com/am-kantox/aston'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.2.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/am-kantox/aston'
  spec.metadata['changelog_uri'] = 'https://github.com/am-kantox/aston/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'prop_check'
  spec.add_development_dependency 'pry'
end
