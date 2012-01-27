# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{ultrasphinx}
  s.version = "1.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = [""]
  s.date = %q{2009-11-18}
  s.description = %q{Ruby on Rails configurator and client to the Sphinx fulltext search engine.}
  s.email = %q{}
  s.extra_rdoc_files = ["CHANGELOG", "DEPLOYMENT_NOTES", "lib/ultrasphinx/is_indexed.rb", "lib/ultrasphinx/search.rb", "lib/ultrasphinx/spell.rb", "lib/ultrasphinx/ultrasphinx.rb", "lib/ultrasphinx.rb", "LICENSE", "RAKE_TASKS", "README", "TODO"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ultrasphinx", "--main", "README"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Ruby on Rails configurator and client to the Sphinx fulltext search engine.}
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test`.split("\n")

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<chronic>, [">= 0"])
    else
      s.add_dependency(%q<chronic>, [">= 0"])
    end
  else
    s.add_dependency(%q<chronic>, [">= 0"])
  end
end
