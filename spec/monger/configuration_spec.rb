describe Monger::Configuration do
  context "when initializing from a file" do
    subject {described_class.from_file("#{environment_root}/config/monger.rb")}

    it "reads and parses the script in the file" do
      subject.database.should eq 'monger-test'
      subject.host.should eq 'localhost'
      subject.port.should eq 27017
      subject.js_namespace.should eq 'Test'
      subject.debug.should be_false
      [Domain, Domain::Auth].each {|mod| subject.modules.should include(mod)}
    end

    it "can build objects from class names" do
      obj = subject.build_object_of_type(:blog_post)
      obj.should be_is_a(Domain::BlogPost)
    end  
  end  

  it "provides hooks for mongo events" do
    subject.hook_mongo :before_read do |type, criteria|
    end
    subject.hook_mongo :before_write do |type, doc|
    end

    subject.mongo_hooks[:before_read].should have_exactly(1).items
    subject.mongo_hooks[:before_write].should have_exactly(1).items
  end
end