require 'monger/mapping/map'

module Monger
  module Dsl
    class MappingExpression
      attr_reader :map
      
      def initialize(configuration, type)
        @type = type
        @map = Monger::Mapping::Map.new
        @klass = configuration.build_class_of_type type
      end

      def all_properties
      end

      def exclude(type)
      end

      def has_a(type, options={})
      end

      def has_many(type, options={})
      end
    end
  end
end
