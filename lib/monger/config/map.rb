module Monger
  module Config
    class Map
      attr_reader :properties
      
      def initialize
        @properties = {}
      end

      def add_property(name, options={})
        type = options[:type] || Monger::Config::PropertyTypes::Direct
        klass = options[:klass] || nil
        @properties[name] = Property.new do |p|
          p.name = name
          p.type = type
          p.klass = klass
        end
      end
    end
  end
end