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

  it "builds reference properties" do
    subject.has_a :author, :type => :user
    property = subject.map.properties[:author]
    property.name.should eq :author
    property.mode.should eq Monger::Config::PropertyModes::Reference
    property.klass.should eq Domain::Auth::User
  end

  it "builds collection properties" do
    subject.has_many :comments, :type => :comment
    property = subject.map.properties[:comments]
    property.name.should eq :comments
    property.mode.should eq Monger::Config::PropertyModes::Collection
    property.klass.should eq Domain::Comment
    property.ref_name.should eq :blog_post
    property.should_not be_update
    property.should_not be_inline
  end

  it "supports reference options" do
    subject.has_a :related_links, :type => :related, :inline => true
    property = subject.map.properties[:related_links]
    property.should be_inline
  end

  it "supports collection options" do
    subject.has_many :tags, :type => :tag, :ref_name => :some_name, :update => true, :inline => true
    property = subject.map.properties[:tags]
    property.ref_name.should eq :some_name
    property.should be_update
    property.should be_inline
  end
end