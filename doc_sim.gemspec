# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "doc_sim/version"

Gem::Specification.new do |s|
  s.name        = "doc_sim"
  s.version     = DocSim::VERSION
  s.authors     = ["Alan Graham"]
  s.email       = ["alangraham5@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{Document similarity library}
  s.description = %q{Document analysis and similarity library}

  s.rubyforge_project = "doc_sim"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

	s.add_dependency "stemmer"

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
