require 'rake' 
require 'rspec/core/rake_task' 
require 'echoe'
  
Echoe.new("monger", "0.0.1") do |p|  
  p.description     = "Super simple ODM for Mongo"  
  p.url             = "http://jarrodpeace.com"  
  p.author          = "Jarrod Peace"  
  p.email           = "peace.jarrod@gmail.com"  
  p.ignore_pattern  = FileList[".gitignore"]  
  p.development_dependencies = ["debugger"]
  p.runtime_dependencies = ["mongo", "bson_ext"]
end  
  
Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each { |ext| load ext }


desc "Default task - runs specs"
task :default => :spec

desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = '-cfd'
end