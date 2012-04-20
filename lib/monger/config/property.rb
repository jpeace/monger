module Monger
  module Config
    class Property
      attr_accessor :name, :mode, :klass
      attr_accessor :ref_name, :update, :inline

      def initialize
        yield self if block_given?
      end

      def update?
        @update
      end

      def inline?
        @inline
      end

      def type
        klass.build_symbol
      end
    end
  end
end