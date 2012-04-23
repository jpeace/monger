module Monger
  module Json
    class Mapper
      def initialize(config)
        @config = config
      end

      def get_hash(obj)
        type = obj.class.build_symbol
        map = @config.maps[type]
        raise ArgumentError if map.nil?

        hash = {}
        map.properties.each do |name, prop|
          val = obj.get_property(name)
          if val.nil?
            hash[name.to_s] = nil
          else
            case prop.mode
            when :direct
              hash[name.to_s] = val
            when :reference
              hash[name.to_s] = get_hash(val) unless val.nil?
            when :collection
              hash[name.to_s] = []
              val.each {|i| hash[name.to_s] << get_hash(i)}
            end
          end
        end

        hash['id'] = obj.monger_id unless obj.monger_id.nil?

        hash
      end

      def from_hash(type, hash)
        map = @config.maps[type]
        raise ArgumentError if map.nil?

        obj = @config.build_object_of_type(type)
        map.properties.each do |name, prop|
          val = hash[name.to_s]
          next if val.nil?

          case prop.mode
          when :direct
            obj.set_property(name, val)
          when :reference
            obj.set_property(name, from_hash(prop.type, val))
          when :collection
            coll = []
            val.each {|i| coll << from_hash(prop.type, i)}
            obj.set_property(name, coll)
          end
        end

        obj.monger_id = hash['id'] unless hash['id'].nil?

        obj
      end

      def entity_to_json(obj)
        get_hash(obj).to_json
      end

      def json_to_entity(type, json)
        from_hash(type, JSON.parse(json))
      end
    end
  end
end