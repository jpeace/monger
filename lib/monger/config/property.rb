module Monger
  module Config
    class Property
      attr_accessor :name, :mode, :klass
      attr_accessor :ref_name, :update, :inline, :delete, :inverse, :always_read, :read_by_default

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

      def always_read?
        @always_read
      end

      def read_by_default?
        @read_by_default
      end

      def type
        klass.build_symbol
      end
    end
  end
end