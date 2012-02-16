require 'monger/mapping/map'

module Monger
  module Dsl
    class MappingExpression
      def initialize(mapper)
        @mapper = mapper
      end

      def map(entity)
        @mapper.maps[]
      end
    end
  end
end
