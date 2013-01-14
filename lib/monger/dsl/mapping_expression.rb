require 'monger/config/map'

module Monger
  module Dsl
    class MappingExpression
      attr_reader :map
      
      def initialize(config, type)
        @config = config
        @type = type
        @map = Monger::Config::Map.new(config.find_class(type))
      end

      def properties(*names)
        names.each do |name|
          @map.add_property(name)
        end
      end

      def date(name)
        @map.add_property(name, nil, :date)
      end

      def time(name)
        @map.add_property(name, nil, :time)
      end

      def has_a(name, options={})
        raise ArgumentError, "Type not found for #{name}." if options[:type].nil?
        type = options[:type]
        #map = @config.maps[type] this won't work yet because not all maps necessarily exist at the time of building this one
        klass = @config.find_class(type)
        @map.add_property(name, klass, :reference, options)
      end

      def has_many(name, options={})
        raise ArgumentError, "Type not found for #{name}." if options[:type].nil?
        type = options[:type]
        #map = @config.maps[type]
        klass = @config.find_class(type)
        options[:ref_name] ||= @type
        @map.add_property(name, klass, :collection, options)
      end
    end
  end
end