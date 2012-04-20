module Monger
  module Config
    class Map
      attr_reader :properties
      
      def initialize
        @properties = {}
      end

      def add_property(name, klass=nil, mode=Monger::Config::PropertyModes::Direct, options={})
        ref_name = options[:ref_name] || nil
        update = options[:update] || false
        inline = options[:inline] || false
        @properties[name] = Property.new do |p|
          p.name = name
          p.mode = mode
          p.klass = klass
          p.ref_name = ref_name
          p.update = update
          p.inline = inline
        end
      end
    end
  end
end