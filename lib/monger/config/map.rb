module Monger
  module Config
    class Map

      attr_reader :entity_class, :type, :properties, :reference_properties, :collection_properties
      
      def initialize(class_guess, type)
        @entity_class = class_guess
        @type = type
        @properties = {}
        @reference_properties = {}
        @collection_properties = {}
      end

      def build_entity
        @entity_class.new
      end

      def indirect_properties
        @reference_properties.concat @collection_properties
      end

      def inverse_collection_properties
        collection_properties.select{|n,p| p.inverse? and not p.inline?}
      end

      def mapped_collection_properties
        collection_properties.select{|n,p| not p.inverse? and not p.inline?}
      end

      def add_property(name, type)
        @properties[name] = Property.new(name, type)
      end

      def add_reference_property(name, klass, options={})
        type = options[:related_by] || :reference
        raise ArgumentError, "#{type} is not a valid reference type." unless [ :value, :reference ].include? type

        load_type = options[:load_type] || :lazy
        raise ArgumentError, "#{load_type} is not a valid load type." unless [ :lazy, :eager ].include? load_type

        delete = options[:delete] || false

        parent_property_name = options[:related_to_parent_by]

        @reference_properties[name] = ReferenceProperty.new(name, klass) do |prop|
          prop.inline = type == :value
          prop.delete = delete
          prop.load_type = load_type
          attr_accessor :ref_name
        end
      end

      # TODO: finish this function
      def add_collection_property(name, klass, options={})
        @reference_properties[name] = CollectionProperty.new(name, klass) do |prop|

        end
      end
    end
  end
end