describe Monger::Ember::CodeGenBinding do
  subject {described_class.new(Mocks::real_config, :blog_post)}

  it "exposes javascript namespaces" do
    subject.domain_namespace.should eq 'Test.Domain'
    subject.mapper_namespace.should eq 'Test.Mappers'
    subject.cache_module.should eq 'Test.Cache'
  end

  it "exposes the object name" do
    subject.object_name.should eq 'BlogPost'
  end

  it "exposes the Javascript name" do
    subject.javascript_name.should eq 'blogPost';
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

  it "exposes a mapping list" do
    mapping_list = %{id:obj.id,
author:author,
body:body,
comments:comments,
relatedLinks:relatedLinks,
tags:tags,
title:title}
    subject.mapping_list.should eq mapping_list
  end

  context "when exposing property mappers" do
    it "works with direct properties" do
      subject.property_mapper_for(:body).should eq 'var body = obj.body;'
    end

    it "works with reference properties" do
      subject.property_mapper_for(:author).should eq 'var author = Test.Mappers.user(obj.author);'
    end

    it "works with collection properties" do
      comment_mapper = %{var comments = [];
for (var i = 0 ; i < obj.comments.length ; ++i) {
  comments.push(Test.Mappers.comment(obj.comments[i]));
}}
      subject.property_mapper_for(:comments).should eq comment_mapper
    end

    it "works with inline reference properties" do
      subject.property_mapper_for(:related_links).should eq 'var relatedLinks = obj.relatedLinks;'
    end

    it "works with inline collection properties" do
      subject.property_mapper_for(:tags).should eq 'var tags = obj.tags;'
    end
  end
end