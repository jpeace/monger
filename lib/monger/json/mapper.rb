module Monger
  module Json
    class Mapper
      def initialize(config)
        @config = config
      end

      def get_hash(obj, depth)
        return obj.class.to_s if depth < 0

        if obj.is_a? Array
          return obj.map {|i| get_hash(i, depth-1)}
        end

        type = obj.class.build_symbol
        map = @config.maps[type]
        raise ArgumentError, "Map not found for #{type}." if map.nil?

        hash = {}
        map.properties.each do |name, prop|
          val = obj.get_property(name)
          js_name = name.build_javascript_name
          if val.nil?
            hash[js_name] = nil
          else
            case prop.mode
              when :date
                hash[js_name] = val.strftime('%-m/%-d/%Y')
              when :time
                hash[js_name] = val.to_12_hour
              when :reference
                hash[js_name] = get_hash(val, depth-1) unless val.nil?
              when :collection
                hash[js_name] = val.map {|i| get_hash(i, depth-1)}
              else
                hash[js_name] = val
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
        raise ArgumentError, "Map not found for #{type}." if map.nil?

        obj = @config.build_object_of_type(type)
        map.properties.each do |name, prop|
          val = hash[name.build_javascript_name]
          next if val.nil?

          case prop.mode
            when :date
              pieces = val.split('/')
              if pieces.length == 3
                obj.set_property(name, Time.utc(pieces[2], pieces[0], pieces[1]))
              end
            when :time
              obj.set_property(name, TimeOfDay.from_string(val))
            when :reference
              obj.set_property(name, from_hash(prop.type, val))
            when :collection
              obj.set_property(name, val.map{|i| from_hash(prop.type, i)})
            else
              obj.set_property(name, val)
          end
        end

        obj.monger_id = hash['id'].to_s.to_monger_id unless hash['id'].nil? || hash['id'] == ''

        obj
      end

      def entity_to_json(obj, depth=0)
        get_hash(obj, depth).to_json
      end

      def json_to_entity(type, json)
        from_hash(type, JSON.parse(json))
      end
    end
  end
end