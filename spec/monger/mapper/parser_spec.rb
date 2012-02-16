require 'monger/mapping/parser'

describe Monger::Mapping::Parser do
  include Mocks

  subject {described_class.new(config)}

  map_script =
%{map :blog_post do |p|
end

map :user do |u|
end}
  
  transformed = 
%{map Domain::BlogPost do |p|
end

map Domain::Auth::User do |u|
end}

  it "transforms entity tokens in mapping script" do
    subject.transform(map_script).should eq transformed
  end

  it "raises script error on unknown entities" do
    bad_script = %{
      map :not_known do |e|
      end
    }
     expect {subject.transform(bad_script)}.to raise_error(ScriptError)
  end

  context "when initializing from a file" do
    subject {described_class.from_file("#{environment_root}/config/map.rb", config)}
    transformed_from_file = 
%{map Domain::BlogPost do |p|
  p.all_properties
end

map Domain::Auth::User do |u|
  u.all_properties
  u.exclude :full_name
  u.has_many :posts
end}    
    
    it "immediately transforms" do
      subject.script.should eq transformed_from_file
    end
  end
end