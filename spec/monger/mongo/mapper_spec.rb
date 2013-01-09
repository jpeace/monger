require "../../spec_helper"

include Database

describe Monger::Mongo::Mapper do

  context "when converting a document to an entity" do
    api = Mocks::Api.new
    subject {described_class.new(api)}

    before(:each) do
      real_config = Mocks.real_config
      blog_post_doc = find_in_db(:blog_post, Database::blog_post_id)
      user_doc = find_in_db(:user, Database::user_id)
      user_doc['co_posts'] = Database::db['blog_post'].find({ :coauthor_id => Database::user_id }).map {|post| post.monger_id}
      @blog_post = subject.doc_to_entity(real_config.maps[:blog_post], blog_post_doc)
      @user = subject.doc_to_entity(real_config.maps[:user], user_doc)
    end

    it "can map to the correct entity type" do
      @blog_post.should be_a Domain::BlogPost
    end

    it "can map basic direct properties" do
      @blog_post.title.should eq "Blog Post"
    end

    it "can map direct date properties" do
      @blog_post.date.should eq Time.utc(2012, 5, 16)
    end

    it "can map direct time properties" do
      @blog_post.time.should be_a ::TimeOfDay
      @blog_post.time.hour.should eq 21
    end

    it "can map inline references" do
      @blog_post.related_links.should be_a Domain::Related
      @blog_post.related_links.urls.should eq %w(http://www.google.com)
    end

    it "can map references set to be eager loaded" do
      @blog_post.author.should be_a Domain::Auth::User
      @blog_post.author.name.should eq "John Doe"
    end

    it "can map references set to be lazy loaded" do
      @blog_post.coauthor.should be_a Monger::Mongo::Placeholders::LazyReferencePlaceholder
      @blog_post.coauthor.name.should eq "Jane Smith"
      @blog_post.coauthor.should be_a Domain::Auth::User
    end

    it "can map inline collections" do
      @blog_post.tags[0].should be_a Domain::Tag
      @blog_post.tags[0].name.should eq "tag1"
    end

    it "can map inverse collections set to be eager loaded" do
      @blog_post.shares.should be_a Monger::Mongo::Placeholders::EagerInverseCollectionPlaceholder
      @blog_post.shares[0].name.should eq "Jane Smith"
      @blog_post.shares.should be_a Array
      @blog_post.shares[0].should be_a Domain::Auth::User
    end

    it "can map inverse collections set to be lazy loaded" do
      @user.likes.class.should eq Array
      @user.likes[0].should be_a Monger::Mongo::Placeholders::LazyCollectionReferencePlaceholder
      @user.likes[0].title.should eq "Post1"
      @user.likes[0].should be_a Domain::BlogPost
      @user.likes[1].should be_a Monger::Mongo::Placeholders::LazyCollectionReferencePlaceholder
    end

    it "can map mapped collections set to be eager loaded" do
      @user.comments.should be_a Monger::Mongo::Placeholders::EagerMappedCollectionPlaceholder
      @user.comments[0].message.should eq "A comment"
      @user.comments.should be_a Array
      @user.comments[0].should be_a Domain::Comment
    end

    it "can map mapped collections set to be lazy loaded" do
      @user.co_posts.should be_a Monger::Mongo::Placeholders::LazyMappedCollectionPlaceholder
      @user.co_posts[0].should be Monger::Mongo::Placeholders::LazyCollectionReferencePlaceholder
      @user.co_posts[0].title.should eq "Blog Post"
      @user.co_posts[0].should be_a Domain::BlogPost
    end
  end

  context "when converting an entity to a document" do
    api = Mocks::Api.new
    subject {described_class.new(api)}

    before(:each) do
      @real_config = Mocks.real_config
      @blog_post_doc = find_in_db(:blog_post, Database::blog_post_id)
      @user_doc = find_in_db(:user, Database::user_id)
      @blog_post = subject.doc_to_entity(@real_config.maps[:blog_post], @blog_post_doc)
      @user = subject.doc_to_entity(@real_config.maps[:user], @user_doc)

      @blog_post.title = "New title"
      @blog_post.date = Time.utc(2013, 4, 26)
      @blog_post.time = TimeOfDay.new(3, 45, 0)
      @blog_post.related_links.urls = %w(http://www.mobleytheband.com http://www.musiconelive.com)
      @blog_post.author = find_in_db(:user, "50eb46cad264870783000004".to_monger_id)
      new_tag = Domain::Tag.new()
      new_tag.name = "tag3"
      @blog_post.tags << new_tag
      @blog_post.shares << find_in_db(:user, "50eb46cad264870783000003".to_monger_id)
      @new_blog_post_doc = subject.entity_to_doc(@real_config.maps[:blog_post], @blog_post)
    end

    it "can map to a full object" do
      @blog_post_to_convert = subject.doc_to_entity(@real_config.maps[:blog_post], @blog_post_doc)
      @user_to_convert = subject.doc_to_entity(@real_config.maps[:user], @user_doc)
      @converted_blog_post_doc = subject.entity_to_doc(@real_config.maps[:blog_post], @blog_post_to_convert)
      @converted_user_doc = subject.entity_to_doc(@real_config.maps[:user], @user)
      @converted_blog_post_doc.should eq @blog_post_doc
      @converted_user_doc.should eq @user_doc
    end

    it "can map basic direct properties" do
      @new_blog_post_doc["title"].should eq "New title"
    end

    it "can map direct date properties" do
      @new_blog_post_doc["date"].should eq Time.utc(2013, 4, 26)
    end

    it "can map direct time properties" do
      @new_blog_post_doc["time"].should eq({ "hour" => 3, "minute" => 45, "second" => 0 })
    end

    it "can map inline references" do
      @new_blog_post_doc["related_links"].should eq({"urls" => %w(http://www.mobleytheband.com http://www.musiconelive.com) })
    end

    it "can map an id for a reference" do
      @new_blog_post_doc["author_id"].should eq "50eb46cad264870783000004".to_monger_id
    end

    it "can map inline collections" do
      @new_blog_post_doc["tags"].length.should eq 3
      @new_blog_post_doc["tags"].should eq [ { "name" => "tag1"}, { "name" => "tag2" }, { "name" => "tag3" } ]
    end

    it "can map an id for an item in a collection" do
      @new_blog_post_doc["shares"].length.should eq 3
      @new_blog_post_doc["shares"].should eq [ "50eb07a1d2648703c3000003".to_monger_id, "50eb46cad264870783000004".to_monger_id, "50eb46cad264870783000003".to_monger_id ]
    end
  end

  context "when converting an entity to a document along with all references" do
    # we have to use a real Api for this in order to enable building references
    db = Monger::Mongo::Database.new(Mocks.real_config)
    api = Monger::Mongo::Api.new(Mocks.real_config, db)
    subject {described_class.new(api)}

    before(:each) do
      real_config = Mocks.real_config
      blog_post_doc = find_in_db(:blog_post, Database::blog_post_id)
      user_doc = find_in_db(:user, Database::user_id)
      blog_post = subject.doc_to_entity(real_config.maps[:blog_post], blog_post_doc)
      edited_blog_post = subject.doc_to_entity(real_config.maps[:blog_post], blog_post_doc)
      user = subject.doc_to_entity(real_config.maps[:user], user_doc)

      edited_blog_post.related_links.urls = %w(http://www.mobleytheband.com http://www.musiconelive.com)
      edited_blog_post.author = find_in_db(:user, "50eb46cad264870783000004".to_monger_id)
      new_tag = Domain::Tag.new()
      new_tag.name = "tag3"
      edited_blog_post.tags << new_tag
      edited_blog_post.shares << find_in_db(:user, "50eb46cad264870783000003".to_monger_id)
      @blog_post_docs = subject.entity_to_docs(real_config.maps[:blog_post], blog_post)
      @edited_blog_post_docs = subject.entity_to_docs(real_config.maps[:blog_post], edited_blog_post)
    end

    it "can ignore placeholder references" do
      @blog_post_docs.length.should eq 1
    end

    it "can ignore placeholder collections" do

    end

    it "can ignore placeholder references in lazy collections" do

    end

    it "can add eager references to the list of docs" do

    end

    it "can add lazy references to the list of docs" do

    end

    it "can add references in an eager collection to the list of docs" do

    end

    it "can add references in a lazy collection to the list of docs" do

    end
  end
end