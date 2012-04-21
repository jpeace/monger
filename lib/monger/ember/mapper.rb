require 'erb'

module Monger
  module Ember
    class Mapper
      def initialize(config)
        @config = config
        @template_path = "#{File.dirname(__FILE__)}/templates"
      end

      def build_object_def(type)
        binding = CodeGenBinding.new(@config, type)
        template = ERB.new(IO.read("#{@template_path}/ember_object.erb"))
        template.result(binding.get_binding)
      end

      def build_mapper(type)
        binding = CodeGenBinding.new(@config, type)
        template = ERB.new(IO.read("#{@template_path}/mapper.erb"))
        template.result(binding.get_binding)
      end

      def domain
        js = "#{@config.js_namespace}.Domain={};\n\n" +
        @config.maps.sort_by{|name,map|name}.map do |name,map|
          build_object_def(name)
        end.join("\n\n")
      end

      def cache
        binding = CodeGenBinding.new(@config)
        template = ERB.new(IO.read("#{@template_path}/cache.erb"))
        template.result(binding.get_binding)
      end

      def mappers
        js = "#{@config.js_namespace}.Mappers={};\n\n" +
        @config.maps.sort_by{|name,map|name}.map do |name,map|
          build_mapper(name)
        end.join("\n\n")
      end

      def javascript
        "#{cache}\n\n#{domain}\n\n#{mappers}"
      end
    end
  end
end