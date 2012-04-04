module Monger
  module Config
    class Map
      attr_reader :properties
      
      def initialize
        @properties = {}
      end

      def add_property(name, options={})
        mode = options[:mode] || Monger::Config::PropertyModes::Direct
        klass = options[:klass] || nil
        @properties[name] = Property.new do |p|
          p.name = name
          p.mode = mode
          p.klass = klass
        end
      end
    end
  end
end