require 'monger/config/map'

module Monger
  module Dsl
    class MappingExpression
      include ::Monger::Dsl::PropertyDefinitions

      attr_reader :map

      def initialize(config, type)
        @config = config
        @type = type
        @map = Monger::Config::Map.new(config.find_class(type), type)
      end

      def method_missing(method, *args, &block)
        plural_method = "#{method}s"
        if self.respond_to? plural_method
          self.method(plural_method).call(*args, &block)
        else
          raise NoMethodError, "#{method}() does not exist on InterfaceExpression."
        end
      end

      def is_a(klass)
        @map.entity_class = klass
      end

      def is_an(klass)
        @map.entity_class = klass
      end

      # TODO: create interfaces
      def is_a_type_of(interface_type)

      end

      # TODO: create default behaviors
      def is(behavior_type)

      end

      def has_string(*names)
        names.each {|name| @map.add_property(name, :string)}
      end

      def has_integer(*names)
        names.each {|name| @map.add_property(name, :integer)}
      end

      def has_number(*names)
        names.each {|name| @map.add_property(name, :number)}
      end

      def has_date(*names)
        names.each {|name| @map.add_property(name, :date)}
      end

      def has_time(*names)
        names.each {|name| @map.add_property(name, :time)}
      end

      def has_email(*names)
        names.each {|name| @map.add_property(name, :email)}
      end

      def has_phone(*names)
        names.each {|name| @map.add_property(name, :phone)}
      end

      def has_a(name, options={})
        options[:is_a] ||= name
        #map = @config.maps[type]
        klass = @config.find_class(options[:is_a])
        @map.add_reference_property(name, klass, options)
      end

      def has_many(name, options={})
        raise ArgumentError if options[:are].nil?
        #map = @config.maps[type]
        klass = @config.find_class(type)
        options[:ref_name] ||= klass.build_symbol
        @map.add_collection_property(name, klass, options)
      end
    end
  end
end