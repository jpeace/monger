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

  context "when reading external configuration files" do
    def original_config
      config = Monger::Configuration.new
      config.maps[:entity] = Monger::Config::Map.new
      return config
    end

    subject do
      c = original_config
      c.parse_external_config_file("#{File.dirname(__FILE__)}/../environment/config/external_config.rb")
      c
    end

    it "brings in the additional configuration" do
      subject.maps.should have_exactly(4).items
    end
  end

  context "when importing external configurations" do
    module Module1
    end

    module Module2
    end

    def main_config
      config = Monger::Configuration.new

      config.database = 'db'
      config.host = 'host'
      config.port = 5000
      config.js_namespace = 'namespace'
      config.debug = false

      config.add_modules([Module1])
      config.hook_mongo :before_read do
      end
      config.maps[:entity] = Monger::Config::Map.new Domain::Tag

      return config
    end

    def external_config
      config = Monger::Configuration.new

      config.database = 'newdb'
      config.host = 'newhost'
      config.port = 1111
      config.js_namespace = 'new_namespace'
      config.debug = true

      config.add_modules([Module1, Module2])
      config.hook_mongo :before_read do
      end
      config.hook_mongo :before_write do
      end
      config.maps[:new_entity] = Monger::Config::Map.new Domain::Tag

      return config
    end

    subject do
      c = main_config
      c.add_external_config(external_config)
      c
    end

    it "ignores the host, port, database, js namespace, and debug settings" do
      subject.database.should eq 'db'
      subject.host.should eq 'host'
      subject.port.should eq 5000
      subject.js_namespace.should eq 'namespace'
      subject.debug.should be_false
    end

    it "brings in the additional modules and does not add more than once" do
      subject.modules.should have_exactly(2).items
      subject.modules.should include(Module1)
      subject.modules.should include(Module2)
    end

    it "brings in the additional hooks" do
      subject.mongo_hooks[:before_read].should have_exactly(2).items
      subject.mongo_hooks[:before_write].should have_exactly(1).items
    end

    it "brings in the additional maps" do
      subject.maps.should have_exactly(2).items
      subject.maps[:entity].should_not be_nil
      subject.maps[:new_entity].should_not be_nil
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