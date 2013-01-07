db = Monger::Mongo::Database

describe Monger::Mongo::Api do
  subject {described_class.new(Mocks::real_config, db)}

  def setup_tag
    t = Domain::Tag.new {|t| t.name = 'TEST TAG'}
    subject.save(t)
  end
  def destroy_tag
    t = subject.find_one(:tag, {:name => 'TEST TAG'})
    subject.remove_entity(t)
  end
  def setup_post(create_user=true)
    p = Domain::BlogPost.new do |bp|
      bp.title = 'TEST POST'
      if create_user
        bp.author = Domain::Auth::User.new do |u|
          u.name = 'TEST USER'
        end
      end
    end
    subject.save(p)
  end
  def destroy_post
    u = subject.find_one(:user, {:name => 'TEST USER'})
    subject.remove_entity(u) unless u.nil?
    p = subject.find_one(:blog_post, {:title => 'TEST POST'})
    subject.remove_entity(p)
  end


  context "when reading" do
    context "simple objects" do
      it "executes the correct number of finds" do
        setup_tag
        db.reset
        
        subject.find_one(:tag, {:name => 'TEST TAG'})
        db.finds.should have_exactly(1).items

        destroy_tag
      end
    end

    context "complex objects" do
      it "executes the correct number of finds with out null relationships" do
        setup_post
        db.reset

        subject.find_one(:blog_post, {:title => 'TEST POST'})
        
        db.finds.should have_exactly(3).items
        db.finds_of_type(:blog_post).should have_exactly(1).items
        db.finds_of_type(:user).should have_exactly(1).items
        db.finds_of_type(:comment).should have_exactly(1).items

        destroy_post
      end

      it "executes the correct number of finds with null relationships" do
        setup_post(false)
        db.reset

        subject.find_one(:blog_post, {:title => 'TEST POST'})
        db.finds.should have_exactly(2).items
        db.finds_of_type(:blog_post).should have_exactly(1).items
        db.finds_of_type(:comment).should have_exactly(1).items

        destroy_post
      end
    end
  end
end