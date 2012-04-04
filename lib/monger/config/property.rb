module Monger
  module Config
    class Property
      attr_accessor :name, :mode, :klass

      def initialize
        yield self if block_given?
      end

      def type
        klass.build_symbol
      end
    end
  end
end