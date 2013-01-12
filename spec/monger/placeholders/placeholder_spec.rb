#require "../../spec_helper"

include Database

describe "Placeholders" do
  real_config = Mocks::real_config
  api = ::Monger::Mongo::Api.new(real_config, ::Monger::Mongo::Database.new(real_config))

  context "when working with a lazy reference" do

    before(:each) do
      @blog_post = api.find_by_id(:blog_post, Database::blog_post_id)
    end

    it "can hydrate upon being accessed" do
      @blog_post.coauthor.should be_a Monger::Placeholders::LazyReferencePlaceholder
      @blog_post.coauthor.name.should eq "Jane Smith"
      @blog_post.coauthor.should be_a Domain::Auth::User
    end
  end

  context "when working with a lazy inverse collection" do

    before(:each) do
      @user = api.find_by_id(:user, Database::user_id)
    end

    it "can hydrate upon being accessed" do
      @user.likes[0].should be_a Monger::Placeholders::LazyCollectionReferencePlaceholder
      @user.likes[0].title.should eq "Post1"
      @user.likes[0].should be_a Domain::BlogPost
      @user.likes[1].should be_a Monger::Placeholders::LazyCollectionReferencePlaceholder
    end

    it "can handle when a collection reference has been independently deleted" do
      api.delete(:blog_post, "50eb46cad264870783000001")
      @user.likes.length.should eq 2
      @user.likes[0].title.should eq "Post2"
      @user.likes.length.should eq 1
    end
  end

  context "when working with a lazy mapped collection" do

    before(:each) do
      @blog_post = api.find_by_id(:blog_post, Database::blog_post_id)
    end

    it "can hydrate upon being accessed" do
      @blog_post.comments.should be_a Monger::Placeholders::LazyMappedCollectionPlaceholder
      @blog_post.comments.length.should eq 3
      @blog_post.comments.should be_a Array
      @blog_post.comments[0].should be_a Monger::Placeholders::LazyCollectionReferencePlaceholder
      @blog_post.comments[0].message.should eq "A comment"
      @blog_post.comments[0].should be_a Domain::Comment
      @blog_post.comments[1].should be_a Monger::Placeholders::LazyCollectionReferencePlaceholder
    end
  end

  context "when working with an eager inverse collection" do

    before(:each) do
      @blog_post = api.find_by_id(:blog_post, Database::blog_post_id)
    end

    it "can hydrate upon being accessed" do
      @blog_post.shares.should be_a Monger::Placeholders::EagerInverseCollectionPlaceholder
      @blog_post.shares[0].name.should eq "Jane Smith"
      @blog_post.shares[0].should be_a Domain::Auth::User
      @blog_post.shares[1].should be_a Domain::Auth::User
    end
  end

  context "when working with an eager mapped collection" do

    before(:each) do
      @user = api.find_by_id(:user, Database::user_id)
    end

    it "can hydrate upon being accessed" do
      @user.comments.should be_a Monger::Placeholders::EagerMappedCollectionPlaceholder
      @user.comments[0].message.should eq "Another comment"
      @user.comments[0].should be_a Domain::Comment
      @user.comments[1].should be_a Domain::Comment
    end
  end
end