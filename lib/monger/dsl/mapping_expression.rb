require 'monger/config/map'

module Monger
  module Dsl
    class MappingExpression
      attr_reader :map
      
      def initialize(config, type)
        @config = config
        @type = type
        @map = Monger::Config::Map.new
      end

      def collection(collection)
        @map.set_collection(collection)
      end

      def properties(*names)
        names.each do |name|
          @map.add_property(name)
        end
      end

      def has_a(name, options={})
        raise ArgumentError if options[:type].nil?
        klass = @config.find_class(options[:type])
        @map.add_property(name, klass, :reference, options)
      end

      def has_many(name, options={})
        raise ArgumentError if options[:type].nil?
        klass = @config.find_class(options[:type])
        options[:ref_name] ||= @type
        @map.add_property(name, klass, :collection, options)
      end
    end
  end
end