describe Monger::Ember::CodeGenBinding do
  subject {described_class.new(Mocks::real_config, :blog_post)}

  it "exposes javascript namespaces" do
    subject.domain_namespace.should eq 'Test.Domain'
    subject.mapper_namespace.should eq 'Test.Mappers'
    subject.cache_namespace.should eq 'Test.Cache'
  end

  it "exposes the object name" do
    subject.object_name.should eq 'BlogPost'
  end

  it "exposes an alphabetized property list" do
    subject.properties.map{|k,v|k}.should eq [:author,:body,:comments,:related_links,:tags,:title]
  end

  it "exposes an initialization list" do
    initialization_list = %{id:'',
author:'',
body:'',
comments:[],
relatedLinks:'',
tags:[],
title:''}
    subject.initialization_list.should eq initialization_list
  end

  it "exposes a serialization list" do
    serialization_list = %{id:this.id,
author:this.author,
body:this.body,
comments:this.comments,
relatedLinks:this.relatedLinks,
tags:this.tags,
title:this.title}
    subject.serialization_list.should eq serialization_list
  end
end