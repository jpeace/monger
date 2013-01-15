module Monger
  module Config
    class CollectionProperty
      attr_accessor :name, :map, :klass
      attr_accessor :ref_name, :inline, :delete, :inverse, :load_type

      def initialize(name, klass)
        @name = name
        @klass = klass
        yield self if block_given?
      end

      def inline?
        @inline
      end

      def delete?
        @delete
      end

      def inverse?
        @inverse
      end

      def eager?
        @load_type == :eager
      end

      def lazy?
        @load_type == :lazy
      end

      def type
        @klass.build_symbol
      end
    end
  end
end
