require 'monger/mapper'
require 'monger/dsl/mapping_expression'

describe Monger::Dsl::MappingExpression do
  mapper = Monger::Mapper.new
  subject { described_class.new(mapper) }

  it "creates a map for the given entity" do
    subject.map Domain::BlogPost
    mapper.maps[:blog_post].should_not be_nil
  end
end