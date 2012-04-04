require 'monger/config/map'

module Monger
  module Dsl
    class MappingExpression
      attr_reader :map
      
      def initialize(config, type)
        @config = config
        @map = Monger::Config::Map.new
      end

      def properties(*names)
        names.each do |name|
          @map.add_property(name)
        end
      end

      def has_a(name, options={})
        raise ArgumentError if options[:type].nil?
        klass = @config.find_class(options[:type])
        @map.add_property(name, :klass => klass, :mode => Monger::Config::PropertyModes::Reference)
      end

      def has_many(name, options={})
        raise ArgumentError if options[:type].nil?
        klass = @config.find_class(options[:type])
        @map.add_property(name, :klass => klass, :mode => Monger::Config::PropertyModes::Collection)
      end
    end
  end
end