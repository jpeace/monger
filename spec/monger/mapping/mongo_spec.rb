describe Monger::Mapping::Mongo do
  subject {described_class.new(Mocks::real_config)}

  it "finds entities by id" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.title.should eq 'Blog Post'
  end

  it "works with mongo ids, too" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id.to_mongo_id)
    post.title.should eq 'Blog Post'
  end

  it "adds an id method" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.id.should eq Database::blog_post_id.to_mongo_id
  end

  it "maps direct properties" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.title.should eq 'Blog Post'
    post.body.should eq 'Here is a post'
  end

  it "maps reference properties" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.author.should be_is_a Domain::Auth::User
    post.author.name.should eq 'John Doe'
    post.author.age.should eq 42
    post.author.gender.should eq 'Male'
  end

  it "maps collection properties" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.comments.should have_exactly(2).items
    post.comments.each do |c|
      ['A comment', 'Another comment'].should include(c.message)
    end
  end

  it "maps to a given depth" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 2)
    post.author.posts.first.title.should eq 'Blog Post'
    post.author.posts.first.author.should be_nil
  end
end