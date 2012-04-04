require 'monger/config'

describe Monger::Configuration do
  context "when initializing from a file" do
    subject {described_class.from_file("#{environment_root}/config/config.rb")}

    it "reads and parses the script in the file" do
      subject.database.should eq 'my_db'
      subject.host.should eq 'localhost'
      subject.port.should eq 8888
      [Domain, Domain::Auth].each {|mod| subject.modules.should include(mod)}
    end

    it "can build objects from class names" do
      obj = subject.build_object_of_type(:blog_post)
      obj.should be_is_a(Domain::BlogPost)
    end
  end  
end