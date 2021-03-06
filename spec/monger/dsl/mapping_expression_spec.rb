require 'monger/dsl/mapping_expression'

include Mocks

describe Monger::Dsl::MappingExpression do
  subject { described_class.new(config, :blog_post) }

  it "builds a property for each name in a property list" do
    subject.properties :title, :body
    subject.map.properties.should have_exactly(2).items
    subject.map.properties[:title].name.should eq :title
    subject.map.properties[:body].name.should eq :body
  end

  it "accepts multiple property lists" do
    subject.properties :title
    subject.map.properties.should have_exactly(1).items
    subject.properties :body
    subject.map.properties.should have_exactly(2).items
  end

  it "builds date properties" do
    subject.date :date
    property = subject.map.properties[:date]
    property.name.should eq :date
    property.mode.should eq :date
  end

  it "builds time properties" do
    subject.time :time
    property = subject.map.properties[:time]
    property.name.should eq :time
    property.mode.should eq :time
  end

  it "builds reference properties" do
    subject.has_a :author, :type => :user
    property = subject.map.properties[:author]
    property.name.should eq :author
    property.mode.should eq :reference
    property.klass.should eq Domain::Auth::User
    property.should_not be_inline
    property.should_not be_delete
    property.should_not be_always_read
    property.should be_read_by_default
  end

  it "builds collection properties" do
    subject.has_many :comments, :type => :comment
    property = subject.map.properties[:comments]
    property.name.should eq :comments
    property.mode.should eq :collection
    property.klass.should eq Domain::Comment
    property.ref_name.should eq :blog_post
    property.should_not be_update
    property.should_not be_inline
    property.should_not be_delete
    property.should_not be_inverse
    property.should_not be_always_read
    property.should be_read_by_default
  end

  it "supports reference options" do
    subject.has_a :related_links, :type => :related, :inline => true, :delete => true, :always_read => true, :read_by_default => false
    property = subject.map.properties[:related_links]
    property.should be_inline
    property.should be_delete
    property.should be_always_read
    property.should_not be_read_by_default
  end

  it "supports collection options" do
    subject.has_many :tags, :type => :tag, :ref_name => :some_name, :update => true, :inline => true, :delete => true, :inverse => true, :always_read => true, :read_by_default => false
    property = subject.map.properties[:tags]
    property.ref_name.should eq :some_name
    property.should be_update
    property.should be_inline
    property.should be_delete
    property.should be_inverse
    property.should be_always_read
    property.should_not be_read_by_default
  end
end