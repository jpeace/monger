module Monger
  module Config
    class Property
      attr_accessor :name, :type, :klass

      def initialize
        yield self if block_given?
      end
    end
  end
end