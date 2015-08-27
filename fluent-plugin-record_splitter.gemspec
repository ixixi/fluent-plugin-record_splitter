# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "fluent-plugin-record_splitter"
  gem.description = "output split array plugin for fluentd"
  gem.homepage    = "https://github.com/ixixi/fluent-plugin-record_splitter"
  gem.summary     = gem.description
  gem.version     = File.read("VERSION").strip
  gem.authors     = ["Yuri Odagiri"]
  gem.email       = "ixixizko@gmail.com"
  gem.has_rdoc    = false
  gem.license     = ''
  gem.files       = `git ls-files`.split("\n")
  gem.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ['lib']

  gem.add_dependency "fluentd", [">= 0.10.58", "< 2"]
  gem.add_dependency "fluent-mixin-config-placeholders", ">= 0.3.0"
  gem.add_development_dependency "rake", ">= 0.9.2"
end
