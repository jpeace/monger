describe Monger::Mongo::Mapper do
  subject {described_class.new(Mocks::real_config)}

  def setup_tag
    t = Domain::Tag.new {|t| t.name = 'TEST TAG'}
    subject.save(t)
  end
  def destroy_tag
    t = subject.find_one(:tag, {:name => 'TEST TAG'})
    subject.remove_entity(t)
  end

  context "when reading" do
    context "simple objects" do
      it "executes the correct number of finds" do
        Monger::Mongo::Database.reset
        setup_tag

        subject.find_one(:tag, {:name => 'TEST TAG'})
        Monger::Mongo::Database.finds.should have_exactly(1).items
        
        destroy_tag
      end
    end
  end
end