module Monger
  module Config
    class Map

      attr_reader :entity_class, :properties
      
      def initialize(entity_class)
        @entity_class = entity_class
        @properties = {}
      end

      def build_entity
        @entity_class.new
      end

      def direct_properties
        @properties.select{|n,p| p.mode == :direct}
      end

      def indirect_properties
        @properties.select{|n,p| p.mode != :direct}
      end

      def reference_properties
        @properties.select{|n,p| p.mode == :reference}
      end

      def collection_properties
        @properties.select{|n,p| p.mode == :collection}
      end

      def inverse_collection_properties
        collection_properties.select{|n,p| p.inverse?}
      end

      def mapped_collection_properties
        collection_properties.select{|n,p| not p.inverse?}
      end

      def add_property(name, klass=nil, mode=:direct, options={})
        ref_name = options[:ref_name] || nil
        update = options[:update] || false
        inline = options[:inline] || false
        delete = options[:delete] || false
        inverse = options[:inverse] || false
        load_type = options[:load_type] || :lazy
        @properties[name] = Property.new do |p|
          p.name = name
          p.mode = mode
          p.klass = klass
          p.ref_name = ref_name
          p.update = update
          p.inline = inline
          p.delete = delete
          p.inverse = inverse
          p.load_type = load_type
        end
      end
    end
  end
end