# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "monger"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jarrod Peace"]
  s.date = "2012-04-18"
  s.description = "Super simple ODM for Mongo"
  s.email = "peace.jarrod@gmail.com"
  s.extra_rdoc_files = ["README.rdoc", "lib/monger.rb", "lib/monger/version.rb"]
  s.files = ["Gemfile", "Gemfile.lock", "Manifest", "README.rdoc", "Rakefile", "lib/monger.rb", "lib/monger/version.rb", "monger.gemspec", "spec/spec_helper.rb"]
  s.homepage = "http://jarrodpeace.com"
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Monger", "--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = "monger"
  s.rubygems_version = "1.8.10"
  s.summary = "Super simple ODM for Mongo"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo>, ["1.7.0"])
      s.add_runtime_dependency(%q<bson>, ["1.7.0"])
      s.add_runtime_dependency(%q<bson_ext>, ["1.7.0"])
    else
      s.add_dependency(%q<mongo>, ["1.7.0"])
      s.add_dependency(%q<bson>, ["1.7.0"])
      s.add_dependency(%q<bson_ext>, ["1.7.0"])
    end
  else
    s.add_dependency(%q<mongo>, ["1.7.0"])
    s.add_dependency(%q<bson>, ["1.7.0"])
    s.add_dependency(%q<bson_ext>, ["1.7.0"])
  end
end
