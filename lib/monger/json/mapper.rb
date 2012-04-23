module Monger
  module Json
    class Mapper
      def initialize(config)
        @config = config
      end

      def get_hash(obj)
        if obj.is_a? Array
          return obj.map {|i| get_hash(i)}
        end

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
              hash[name.to_s] = val.map {|i| get_hash(i)}
            end
          end
        end

        hash['id'] = obj.monger_id.to_s unless obj.monger_id.nil?

        hash
      end

      def from_hash(type, hash)
        if hash.is_a? Array
          return hash.map {|i| from_hash(type, i)}
        end

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
            obj.set_property(name, val.map{|i| from_hash(prop.type, i)})
          end
        end

        obj.monger_id = hash['id'].to_s.to_monger_id unless hash['id'].nil?

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