require 'monger/mapper'
require 'monger/dsl/mapping_expression'

describe Monger::Dsl::MappingExpression do
  mapper = Monger::Mapper.new
  subject { described_class.new(mapper) }
end