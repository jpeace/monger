describe Monger::Ember::Mapper do  
  subject {described_class.new(Mocks::real_config)}

  def codegen(codegen)
    IO.read("#{environment_root}/codegen/#{codegen}")
  end
  
  it "can build Ember object definitions" do
    subject.build_object_def(:blog_post).should eq codegen('ember_object.js')
  end

  it "can build mapper functions" do
    subject.build_mapper(:blog_post).should eq codegen('mapper.js')
  end

  it "can build the cache module" do
    subject.cache.should eq codegen('cache.js')
  end
end