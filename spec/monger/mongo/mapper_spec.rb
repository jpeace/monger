include Database

describe Monger::Mongo::Mapper do
  api = Mocks::Api.new
  subject {described_class.new(api)}

  context "when converting a document to an entity" do

    before(:each) do
      real_config = Mocks.real_config
      blog_post_doc = find_in_db(:blog_post, Database::blog_post_id)
      user_doc = find_in_db(:user, Database::user_id)
      user_doc['co_posts'] = Database::db['blog_post'].find({ :coauthor_id => Database::user_id }).map {|post| post.monger_id}
      @blog_post = subject.doc_to_entity(real_config.maps[:blog_post], blog_post_doc)
      @user = subject.doc_to_entity(real_config.maps[:user], user_doc)
    end

    it "can map to the correct entity type" do
      @blog_post.class.should eq Domain::BlogPost
    end

    it "can map basic direct properties" do
      @blog_post.title.should eq "Blog Post"
    end

    it "can map direct date properties" do
      @blog_post.date.should eq Time.utc(2012, 5, 16)
    end

    it "can map direct time properties" do
      @blog_post.time.class.should eq ::TimeOfDay
      @blog_post.time.hour.should eq 21
    end

    it "can map references stored inline" do
      @blog_post.related_links.class.should eq Domain::Related
      @blog_post.related_links.urls.should eq %w(http://www.google.com)
    end

    it "can map references set to be eager loaded" do
      @blog_post.author.class.should eq Domain::Auth::User
      @blog_post.author.name.should eq "John Doe"
    end

    it "can map references set to be lazy loaded" do
      @blog_post.coauthor.class.should eq Monger::Mongo::Placeholders::LazyReferencePlaceholder
      @blog_post.coauthor.name.should eq "John Doe"
      @blog_post.coauthor.class.should eq Domain::Auth::User
    end

    it "can map inline collections" do
      @blog_post.tags[0].class.should eq Domain::Tag
      @blog_post.tags[0].name.should eq "tag1"
    end

    it "can map inverse collections set to be eager loaded" do
      @blog_post.shares.class.should eq Monger::Mongo::Placeholders::EagerInverseCollectionPlaceholder
      @blog_post.shares[0].name.should eq "Jane Smith"
      @blog_post.shares.class.should eq Array
      @blog_post.shares[0].class.should eq Domain::Auth::User
    end

    it "can map inverse collections set to be lazy loaded" do
      @user.likes.class.should eq Array
      @user.likes[0].class.should eq Monger::Mongo::Placeholders::LazyCollectionPlaceholder
      @user.likes[0].title.should eq "Post1"
      @user.likes[0].class.should eq Domain::BlogPost
      @user.likes[1].class.should eq Monger::Mongo::Placeholders::LazyCollectionPlaceholder
    end

    it "can map mapped collections set to be eager loaded" do
      @user.comments.class.should eq Monger::Mongo::Placeholders::EagerMappedCollectionPlaceholder
      @user.comments[0].message.should eq "A comment"
      @user.comments.class.should eq Array
      @user.comments[0].class.should eq Domain::Comment
    end

    it "can map mapped collections set to be lazy loaded" do
      @user.co_posts.class.should eq Array
      @user.co_posts[0].class.should eq Monger::Mongo::Placeholders::LazyCollectionPlaceholder
      @user.co_posts[0].title.should eq "Blog Post"
      @user.co_posts[0].class.should eq Domain::BlogPost
    end

    it "can convert multiple documents into entities" do

    end
  end

  context "when converting an entity to a document" do

  end
end