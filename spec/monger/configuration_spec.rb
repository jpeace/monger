describe Monger::Configuration do
  context "when initializing from a file" do
    subject {described_class.from_file("#{environment_root}/config/monger.rb")}

    it "reads and parses the script in the file" do
      subject.database.should eq 'monger-test'
      subject.host.should eq 'localhost'
      subject.port.should eq 27017
      subject.js_namespace.should eq 'Test'
      [Domain, Domain::Auth].each {|mod| subject.modules.should include(mod)}
    end

    it "can build objects from class names" do
      obj = subject.build_object_of_type(:blog_post)
      obj.should be_is_a(Domain::BlogPost)
    end
  end  
end