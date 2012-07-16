# -*- encoding: utf-8 -*-
require File.expand_path('../lib/melai/version', __FILE__)

Gem::Specification.new do |gem|

  gem.name          = 'melai'
  gem.summary       = %q{melai builds multi-platform repositories for a given list of files}
  gem.description   = %q{Build your repositories with melai}
  gem.version       = Melai::VERSION
  
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  
  
   # GLI (Github-Like Interface) http://davetron5000.github.com/gli/
  gem.add_dependency 'gli'

  # versiononmy http://dazuma.github.com/versionomy/
  gem.add_dependency 'versionomy'

  # MixLib::ShellOut to perform system-level commands
  gem.add_dependency 'mixlib-shellout'
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'aruba'
  gem.add_development_dependency 'aruba-doubles'
  gem.add_development_dependency 'pry'

  # tailor, for style. https://github.com/turboladen/tailor
  gem.add_development_dependency 'tailor'

  gem.authors       = ["Mike Fiedler"]
  gem.email         = ["miketheman@gmail.com"]
  gem.homepage      = "http://www.miketheman.net"  
  
end
