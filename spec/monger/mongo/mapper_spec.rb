include Database

describe Monger::Mongo::Mapper do
  subject {described_class.new(Mocks::real_config)}

  context "when searching" do
    it "builds search criteria" do
      subject.build_search_criteria(:blog_post, 'term').should eq ({'$or' => [{'title' => /term/i}, {'body' => /term/i}]})
    end

    it "can build a search criteria for the specified fields" do
      subject.build_search_criteria(:blog_post, 'term', [:title]).should eq ({'$or' => [{'title' => /term/i}]})
    end
  end

  context "when reading" do
    it "finds entities by id" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.title.should eq 'Blog Post'
    end

    it "works with monger ids, too" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id.to_monger_id)
      post.title.should eq 'Blog Post'
    end

    it "adds a monger id" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.monger_id.should eq Database::blog_post_id.to_monger_id
    end

    it "reads direct properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.title.should eq 'Blog Post'
      post.body.should eq 'Here is a post'
    end

    it "reads reference properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.author.should be_is_a Domain::Auth::User
      post.author.name.should eq 'John Doe'
      post.author.age.should eq 42
      post.author.gender.should eq 'Male'
    end

    it "reads collection properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.comments.should have_exactly(2).items
      post.comments.each do |c|
        ['A comment', 'Another comment'].should include(c.message)
      end
    end

    it "reads to a given depth" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 2)
      post.author.posts.first.title.should eq 'Blog Post'
      post.author.posts.first.author.should be_nil
    end

    it "reads inline properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.related_links.urls.should eq ['http://www.google.com']
      post.tags.should have_exactly(2).items
      post.tags.each do |t|
        ['tag1','tag2'].should include(t.name)
      end
    end

    it "ignores depth for inline properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 0)
      post.author.should be_nil
      post.related_links.urls.should eq ['http://www.google.com']
      post.tags.should have_exactly(2).items
    end

    it "can be configured to ignore certain mappings" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :ignore => [:tags, :author])
      post.author.should be_nil
      post.tags.should be_empty
    end
  end

  context "when writing" do
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

    it "does not update indirect properties by default" do
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

    it "updates indirect properties when they are marked with the :update option" do
      post = Domain::BlogPost.new do |p|
        p.comments = [Domain::Comment.new {|c| c.message = 'Comment!'}]
      end
      subject.save(post, :atomic => true)
      post.comments[0].message = 'New!'
      subject.save(post, :atomic => true)
      doc = find_in_db(:comment, post.comments[0].monger_id)
      doc['message'].should eq 'New!'
    end

    it "writes inline properties" do
      post = Domain::BlogPost.new do |p|
        p.related_links = Domain::Related.new do |r|
          r.urls = ['http://www.google.com']
        end
      end
      post.add_tag('tag1')
      post.add_tag('tag2')

      subject.save(post, :atomic => true)
      
      doc = find_in_db(:blog_post, post.monger_id)
      doc['related_links']['urls'].should eq ['http://www.google.com']
      doc['tags'][0]['name'].should eq 'tag1'
      doc['tags'][1]['name'].should eq 'tag2'
    end
  end

  context "when deleting" do
    it "can remove entities" do
      tag = Domain::Tag.new do |t|
        t.name = 'New Tag'
      end
      subject.save(tag, :atomic => true)

      id = tag.monger_id
      find_in_db(:tag, id).should_not be_nil
      
      subject.delete(:tag, tag.monger_id, :atomic => true)
      find_in_db(:tag, id).should be_nil
    end

    it "removes owned references when marked as such" do
      post = Domain::BlogPost.new do |p|
        p.author = Domain::Auth::User.new {|u| u.name = 'John Doe'}
      end
      subject.save(post, :atomic => true)

      post_id = post.monger_id
      user_id = post.author.monger_id
      find_in_db(:user, user_id).should_not be_nil

      subject.delete(:blog_post, post_id)
      find_in_db(:user, user_id).should be_nil
    end

    it "removes owned collections when marked as such" do
      post = Domain::BlogPost.new do |p|
        p.comments = [Domain::Comment.new {|c| c.message = 'Comment!'}]
      end
      subject.save(post, :atomic => true)

      post_id = post.monger_id
      comment_id = post.comments[0].monger_id
      find_in_db(:comment, comment_id).should_not be_nil

      subject.delete(:blog_post, post_id)
      find_in_db(:comment, comment_id).should be_nil
    end
  end
end