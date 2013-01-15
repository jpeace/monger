module Monger
  module Config
    class Property
      attr_accessor :name, :type

      def initialize(name, type)
        @name = name
        @type = type
        yield self if block_given?
      end

    end
  end
end