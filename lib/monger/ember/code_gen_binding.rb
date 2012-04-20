module Monger
  module Ember
    class CodeGenBinding
      def initialize(config, type)
        @config = config
        @type = type
        @map = @config.maps[@type]
        raise ArgumentError if @map.nil?
      end

      def get_binding
        binding
      end

      def domain_namespace
        "#{@config.js_namespace}.Domain"
      end

      def mapper_namespace
        "#{@config.js_namespace}.Mappers"
      end

      def object_name
        @type.build_class_name
      end

      def properties
        @map.properties.sort_by {|n,v| n}
      end

      def initialization_list
        "id:'',\n" +
        properties.map do |name, prop|
          "#{name}:#{get_default_for_property(prop)}"
        end.join(",\n")
      end

      def serialization_list
        "id:this.id,\n" +
        properties.map do |name, prop|
          "#{name}:this.#{name}"
        end.join(",\n")
      end

      def get_default_for_property(property)
        case property.mode
        when :direct 
          "''"
        when :reference 
          "''"
        when :collection 
          "[]"
        end
      end
    end
  end
end