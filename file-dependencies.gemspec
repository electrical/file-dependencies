#-*- mode: ruby -*-

Gem::Specification.new do |s|
  s.name = 'file-dependencies'
  s.version = "0.1.0"
  s.author = 'Richard Pijnenburg'
  s.email = [ 'richard.pijnenburg@elasticsearch.com' ]
  s.summary = 'manage file dependencies for gems'
  s.homepage = 'https://github.com/electrical/file-dependencies'

  s.license = 'APACHE 2.0'

  s.executable = 'file-deps'

  s.files = `git ls-files`.split($\)

  s.description = 'manage file dependencies for gems'

  s.add_runtime_dependency 'minitar'

  s.add_development_dependency 'rake', '~> 10.2'
end

# vim: syntax=Ruby
