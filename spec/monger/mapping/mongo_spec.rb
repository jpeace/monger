include Database

describe Monger::Mapping::Mongo do
  subject {described_class.new(Mocks::real_config)}

  it "finds entities by id" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.title.should eq 'Blog Post'
  end

  it "works with mongo ids, too" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id.to_monger_id)
    post.title.should eq 'Blog Post'
  end

  it "adds a mongo id" do
    post = subject.find_by_id(:blog_post, Database::blog_post_id)
    post.monger_id.should eq Database::blog_post_id.to_monger_id
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

  it "inserts new entities" do
    post = Domain::BlogPost.new do |p|
      p.title = 'New Post'
    end
    subject.save(post, :atomic => true)
    post.monger_id.should_not be_nil
    doc = find_in_db(:blog_post, post.monger_id)
    doc['title'].should eq 'New Post'

    # Reference
    post.author = Domain::Auth::User.new do |u|
      u.name = 'John Doe'
    end
    subject.save(post, :atomic => true)
    post.author.monger_id.should_not be_nil
    doc = find_in_db(:blog_post, post.monger_id)
    doc['author_id'].should eq post.author.monger_id
    doc = find_in_db(:user, post.author.monger_id)
    doc['name'].should eq 'John Doe'

    # Collections
    post.comments = [Domain::Comment.new {|c| c.message = 'Comment!'}]
    subject.save(post, :atomic => true)
    comment = post.comments.first
    comment.monger_id.should_not be_nil
    doc = find_in_db(:comment, comment.monger_id)
    doc['message'].should eq 'Comment!'
  end

  it "updates direct properties" do
    post = Domain::BlogPost.new do |p|
      p.title = 'New Post'
    end
    subject.save(post, :atomic => true)
    post.title = 'Changed Title'
    subject.save(post, :atomic => true)
    doc = find_in_db(:blog_post, post.monger_id)
    doc['title'].should eq 'Changed Title'
  end

  it "does not update indirect properties" do
    post = Domain::BlogPost.new do |p|
      p.author = Domain::Auth::User.new do |u|
        u.name = 'John Doe'
      end
    end
    subject.save(post, :atomic => true)
    post.author.name = 'New Name'
    subject.save(post, :atomic => true)
    doc = find_in_db(:user, post.author.monger_id)
    doc['name'].should eq 'John Doe'
  end
end