module Monger
  module Config
    class Property
      attr_accessor :name, :mode, :klass, :ref_name, :update

      def initialize
        yield self if block_given?
      end

      def update?
        update
      end

      def type
        klass.build_symbol
      end
    end
  end
end