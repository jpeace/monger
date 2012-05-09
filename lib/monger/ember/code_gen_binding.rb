module Monger
  module Ember
    class CodeGenBinding
      def initialize(config, type=nil)
        @config = config
        if !type.nil?
          @type = type
          @map = @config.maps[@type]
          raise ArgumentError if @map.nil?
        end
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

      def cache_module
        "#{@config.js_namespace}.Cache"
      end

      def object_name
        @type.build_class_name
      end

      def javascript_name
        @type.build_javascript_name
      end

      def properties
        @map.properties.sort_by {|n,v| n}
      end

      def initialization_list
        "id:'',\n" +
        properties.map do |name, prop|
          "#{name.build_javascript_name}:#{get_default_for_property(prop)}"
        end.join(",\n")
      end

      def serialization_setup
        properties.select{|n,p| ![:direct,:date].include?(p.mode) }.map do |name, prop|
          js_name = name.build_javascript_name
          if (prop.mode == :reference)
%{var #{js_name} = null;
if (this.#{js_name}) {
  #{js_name} = this.#{js_name}.serialize();
}}
          elsif (prop.mode == :collection)
%{var #{js_name} = [];
for (var i = 0 ; i < this.#{js_name}.length ; ++i) {
  #{js_name}.push(this.#{js_name}[i].serialize());
}}
          end
        end.join("\n")
      end

      def serialization_list
        "id:this.id,\n" +
        properties.map do |name, prop|
          case prop.mode
          when :direct, :date
            "#{name.build_javascript_name}:this.#{name.build_javascript_name}"
          when :reference, :collection
            "#{name.build_javascript_name}:#{name.build_javascript_name}"
          end
        end.join(",\n")
      end

      def mapping_list
        "id:obj.id,\n" +
        properties.map do |name, prop|
          "#{name.build_javascript_name}:#{name.build_javascript_name}"
        end.join(",\n")
      end

      def property_mapper_for(name)
        prop = @map.properties[name]
        case prop.mode
        when :direct, :date
          direct_mapper(name)
        when :reference
          if prop.inline?
            direct_mapper(name)
          else
            reference_mapper(name, prop.type)
          end
        when :collection
          if prop.inline?
            direct_mapper(name)
          else
            collection_mapper(name, prop.type)
          end
        end
      end

  private

      def direct_mapper(name)
        js_name = name.build_javascript_name
        "var #{js_name} = obj.#{js_name};"
      end

      def reference_mapper(name, type)
        js_name = name.build_javascript_name
        "var #{js_name} = #{mapper_namespace}.#{type.build_javascript_name}(obj.#{js_name});"
      end

      def collection_mapper(name, type)
        js_name = name.build_javascript_name
        %{var #{js_name} = [];
for (var i = 0 ; i < obj.#{js_name}.length ; ++i) {
  #{js_name}.push(#{mapper_namespace}.#{type.build_javascript_name}(obj.#{js_name}[i]));
}}
      end

      def get_default_for_property(property)
        case property.mode
        when :direct, :date, :reference
          "''"
        when :collection 
          "[]"
        end
      end
    end
  end
end