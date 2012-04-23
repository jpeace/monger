require 'json'
include Database

describe Monger::Json::Mapper do
  subject {described_class.new(Mocks.real_config)}

  post = Domain::BlogPost.new do |p|
    p.title = 'Title'
    p.body = 'Body'
    p.author = Domain::Auth::User.new do |u|
      u.name = 'Author'
      u.age = 30
      u.gender = 'M'
    end
    p.comments = [
      Domain::Comment.new do |c|
        c.user = Domain::Auth::User.new do |u|
          u.name = 'Commenter'
          u.age = 22
          u.gender = 'F'
        end
        c.message = 'Comment!'
      end
    ]
    p.tags = [Domain::Tag.new {|t| t.name = 'Tag1'}, Domain::Tag.new {|t| t.name = 'Tag2'}]
    p.related_links = Domain::Related.new do |r|
      r.urls = ['http://www.google.com']
    end
  end

  json = %{
    {
      "id":"#{Database::blog_post_id}",
      "title":"Title",
      "body":"Body",
      "author":{
        "name":"Author",
        "age":30,
        "gender":"M"
      },
      "comments":[
        {
          "user":{
            "id":4,
            "name":"Commenter",
            "age":22,
            "gender":"F"
          },
          "message":"Comment!"
        }
      ],
      "tags":[
        {"name":"Tag1"},
        {"name":"Tag2"}
      ],
      "related_links":{
        "urls":["http://www.google.com"]
      }
    }
  }
  
  context "when serializing" do
    
    it "works with direct properties" do
      hash = subject.get_hash(post)

      hash['title'].should eq 'Title'
      hash['body'].should eq 'Body'
    end

    it "works with reference properties" do
      hash = subject.get_hash(post)

      hash['author'].should be_is_a Hash
      hash['author']['name'].should eq 'Author'
      hash['author']['age'].should eq 30
      hash['author']['gender'].should eq 'M'
    end

    it "works with collections" do
      hash = subject.get_hash(post)

      hash['comments'].should be_is_a Array
      hash['comments'].should have_exactly(1).items
      hash['comments'][0]['message'].should eq 'Comment!'
    end

    it "works with inline references" do
      hash = subject.get_hash(post)

      hash['related_links'].should be_is_a Hash
      hash['related_links']['urls'].should eq ['http://www.google.com']
    end

    it "works with inline collections" do
      hash = subject.get_hash(post)

      hash['tags'].should be_is_a Array
      hash['tags'].should have_exactly(2).items
      hash['tags'][0]['name'].should eq 'Tag1'
      hash['tags'][1]['name'].should eq 'Tag2'
    end

    it "works with monger ids" do
      post.monger_id = Database::blog_post_id.to_monger_id
      hash = subject.get_hash(post)

      hash['id'].should eq Database::blog_post_id
    end
  end

  context "when deserializing" do
    hash = JSON.parse(json)

    it "builds the correct object type" do
      subject.from_hash(:blog_post, hash).should be_is_a Domain::BlogPost
    end

    it "works with direct properties" do
      obj = subject.from_hash(:blog_post, hash)

      obj.title.should eq 'Title'
      obj.body.should eq 'Body'
    end

    it "works with reference properties" do
      obj = subject.from_hash(:blog_post, hash)

      obj.author.should be_is_a Domain::Auth::User
      obj.author.name.should eq 'Author'
      obj.author.age.should eq 30
      obj.author.gender.should eq 'M'
    end

    it "works with collection properties" do
      obj = subject.from_hash(:blog_post, hash)

      obj.comments.should be_is_a Array
      obj.comments.should have_exactly(1).items
      obj.comments[0].should be_is_a Domain::Comment
      obj.comments[0].message.should eq 'Comment!'
    end

    it "works with monger ids" do
      obj = subject.from_hash(:blog_post, hash)
      obj.monger_id.should be_is_a BSON::ObjectId
      obj.monger_id.to_s.should eq Database::blog_post_id
    end
  end

  it "maps entities to json" do
    obj = Domain::Tag.new do |t|
      t.name = 'Tag'
    end
    subject.entity_to_json(obj).should eq '{"name":"Tag"}'
  end

  it "maps entity collections to json" do
    coll = [
      Domain::Tag.new do |t|
        t.name = 'Tag1'
      end,
      Domain::Tag.new do |t|
        t.name = 'Tag2'
      end
    ]
    subject.entity_to_json(coll).should eq '[{"name":"Tag1"},{"name":"Tag2"}]'
  end

  it "maps json to entities" do
    json = '{"name":"Tag"}'
    subject.json_to_entity(:tag, json).name.should eq 'Tag'
  end

  it "maps json collections to entities" do
    json = '[{"name":"Tag1"},{"name":"Tag2"}]'
    tags = subject.json_to_entity(:tag, json)
    tags.should be_is_a Array
    tags.should have_exactly(2).items
    tags[0].name.should eq 'Tag1'
    tags[1].name.should eq 'Tag2'
  end
end