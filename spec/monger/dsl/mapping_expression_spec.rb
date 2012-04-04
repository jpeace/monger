require 'monger/config'
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
    property.type.should eq Monger::Config::PropertyTypes::Reference
    property.klass.should eq Domain::Auth::User
  end

  it "builds collection properties" do
    subject.has_many :comments, :type => :comment
    property = subject.map.properties[:comments]
    property.name.should eq :comments
    property.type.should eq Monger::Config::PropertyTypes::Collection
    property.klass.should eq Domain::Comment
  end
end