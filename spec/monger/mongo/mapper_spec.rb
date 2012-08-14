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

    it "returns null for an invalid BSON id" do
      post = subject.find_by_id(:blog_post, 'bad format')
      post.should be_nil
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

    it "reads date properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.date.should eq Time.utc(2012, 5, 16)
    end

    it "reads time properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id)
      post.time.to_12_hour.should eq '9:30 PM'
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

    it "reads inverse collection properties" do
      user = subject.find(:user, {:name => 'Jane Smith'}).first
      user.likes.should have_exactly(2).items
    end

    it "doesn't read removed items from an inversed collection" do
      post1 = Domain::BlogPost.new do |p|
        p.title = 'Post1'
      end
      post2 = Domain::BlogPost.new do |p|
        p.title = 'Post2'
      end
      subject.save(post1, :atomic => true)
      subject.save(post2, :atomic => true)

      user = Domain::Auth::User.new do |u|
        u.name = 'Test'
        u.likes = [post1, post2]
      end
      subject.save(user, :atomic => true)

      subject.delete(:blog_post, post1.monger_id, :atomic=>true)
      user = subject.find_by_id(:user, user.monger_id)

      user.likes.should have_exactly(1).items
      user.likes[0].title.should eq('Post2')
    end

    it "reads to a given depth" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 2)
      post.author.posts.first.title.should eq 'Blog Post'
      post.author.posts.first.comments.should be_empty
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
      post.comments.should be_empty
      post.related_links.urls.should eq ['http://www.google.com']
      post.tags.should have_exactly(2).items
    end

    it "can be configured to always read certain properties" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 0)
      post.comments.should be_empty
      post.author.should_not be_nil
    end

    it "can be configured to not read certain properties by default" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 2)
      post.author.comments.should be_empty
    end

    it "can be configured to force certain properties to be read" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 2, :force => [:comments])
      post.author.comments.should have_exactly(1).items

      post = subject.find_by_id(:blog_post, Database::blog_post_id, :depth => 0, :force => [:comments])
      post.comments.should have_exactly(2).items
      post.comments.each do |c|
        ['A comment', 'Another comment'].should include(c.message)
      end
    end

    it "can be configured to ignore certain mappings" do
      post = subject.find_by_id(:blog_post, Database::blog_post_id, :ignore => [:tags, :author, :urls])
      post.author.should be_nil
      post.tags.should be_empty
      post.related_links.urls.should be_empty
    end

    it "doesn't map properties when they don't exist in the document" do
      comment = subject.find_one(:comment, {:message => 'A comment'})
      comment.important.should be_true
    end

    it "does map nil properties" do
      comment = subject.find_one(:comment, {:message => 'Another comment'})
      comment.important.should be_nil
    end

    it "supports limits" do
      comments = subject.find(:comment, {}, :limit => 1)
      comments.should have_exactly(1).items
    end

    it "can handle bad limits" do
      comments = subject.find(:comment, {}, :limit => 'not really a limit')
      comments.should have_exactly(2).items
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

    it "does not destroy one to many relationships when editing collection members" do
      post = Domain::BlogPost.new do |p|
        p.title = 'New Post'
        p.comments = [Domain::Comment.new {|c| c.message = 'Comment!'}]
      end
      subject.save(post, :atomic => true)

      comment_id = post.comments[0].monger_id
      comment = subject.find_by_id(:comment, comment_id)
      comment.message = 'Changed!'
      subject.save(comment, :atomic => true)

      post = subject.find_by_id(:blog_post, post.monger_id)
      post.comments.should have_exactly(1).items
      post.comments[0].message.should eq 'Changed!'
    end

    it "writes date properties" do
      post = Domain::BlogPost.new do |p|
        p.date = Time.utc(2012, 5, 16)
      end
      subject.save(post, :atomic => true)
      doc = find_in_db(:blog_post, post.monger_id)
      doc['date'].should eq Time.utc(2012, 5, 16)
    end

    it "writes time properties" do
      post = Domain::BlogPost.new do |p|
        p.time = TimeOfDay.new(5, 30, 35, :am)
      end
      subject.save(post, :atomic => true)
      doc = find_in_db(:blog_post, post.monger_id)
      doc['time']['hour'].should eq 5
      doc['time']['minute'].should eq 30
      doc['time']['second'].should eq 35
    end

    it "correctly add references to existing entities when inserting a new entity" do
      user = Domain::Auth::User.new
      subject.save(user, :atomic => true)

      comment = Domain::Comment.new
      subject.save(comment, :atomic => true)

      post = Domain::BlogPost.new do |p|
        p.author = user
        p.comments = [comment]
      end
      subject.save(post, :atomic => true)

      doc = find_in_db(:blog_post, post.monger_id)
      doc['author_id'].should eq user.monger_id

      doc = find_in_db(:comment, comment.monger_id)
      doc['blog_post_id'].should eq post.monger_id
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

    it "writes inverse collections" do
      post1 = Domain::BlogPost.new do |p|
        p.title = 'Post1'
      end
      post2 = Domain::BlogPost.new do |p|
        p.title = 'Post2'
      end
      subject.save(post1, :atomic => true)
      subject.save(post2, :atomic => true)

      user = Domain::Auth::User.new do |u|
        u.name = 'Test'
        u.likes = [post1, post2]
      end
      subject.save(user, :atomic => true)

      doc = find_in_db(:user, user.monger_id)
      post_ids = doc['likes']
      post_ids.should be_include(post1.monger_id)
      post_ids.should be_include(post2.monger_id)
    end

    it "inserts new elements when writing inverse collections" do
      post1 = Domain::BlogPost.new do |p|
        p.title = 'Post1'
      end
      user = Domain::Auth::User.new do |u|
        u.name = 'Test'
        u.likes = [post1]
      end
      subject.save(user, :atomic => true)

      doc = find_in_db(:user, user.monger_id)
      post_id = doc['likes'][0]
      post = find_in_db(:blog_post, post_id)
      post['title'].should eq 'Post1'
    end

    it "preserves the order of inverse collections" do
      post1 = Domain::BlogPost.new do |p|
        p.title = 'Post1'
      end
      post2 = Domain::BlogPost.new do |p|
        p.title = 'Post2'
      end
      post3 = Domain::BlogPost.new do |p|
        p.title = 'Post3'
      end
      post4 = Domain::BlogPost.new do |p|
        p.title = 'Post4'
      end
      subject.save(post1, :atomic => true)
      subject.save(post2, :atomic => true)
      subject.save(post3, :atomic => true)
      subject.save(post4, :atomic => true)

      user = Domain::Auth::User.new do |u|
        u.name = 'Test'
        u.likes = [post2, post1, post4, post3]
      end
      subject.save(user, :atomic => true)

      user = subject.find_by_id(:user, user.monger_id)
      user.likes[0].title.should eq 'Post2'
      user.likes[1].title.should eq 'Post1'
      user.likes[2].title.should eq 'Post4'
      user.likes[3].title.should eq 'Post3'
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

    it "can remove entities by reference" do
      tag = Domain::Tag.new do |t|
        t.name = 'New Tag'
      end
      subject.save(tag, :atomic => true)

      id = tag.monger_id
      find_in_db(:tag, id).should_not be_nil
      
      subject.remove_entity(tag, :atomic => true)
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