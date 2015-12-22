lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ruboty/postgres/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruboty-postgres'
  spec.version       = Ruboty::Postgres::VERSION
  spec.authors       = ['SHIOYA, Hiromu']
  spec.email         = ['kwappa.856@gmail.com']

  spec.summary       = 'store memory of ruboty in postgresql'
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/kwappa/ruboty-postgres'
  spec.license       = 'MIT'


  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ruboty'
  spec.add_dependency 'pg'

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'test-unit'
end
