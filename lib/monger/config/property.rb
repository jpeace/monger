module Monger
  module Config
    class Property
      attr_accessor :name, :mode, :map, :klass
      attr_accessor :ref_name, :update, :inline, :delete, :inverse, :load_type

      def initialize
        yield self if block_given?
      end

      def update?
        @update
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
        klass.build_symbol
      end
    end
  end
end