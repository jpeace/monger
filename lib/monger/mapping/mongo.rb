require 'mongo'

module Monger
  module Mapping
    class Mongo
      class Database
        def initialize(config)
          @db = ::Mongo::Connection.new(config.host, config.port).db(config.database)
        end

        def find_all(type)
          @db[type.to_s].find
        end

        def find_by_id(type, id)
          @db[type.to_s].find({'_id' => id}).first
        end

        def find(type, criteria={})
          @db[type.to_s].find(criteria)
        end
      end
      
      def initialize(config)
        @config = config
        @db = Database.new(config)
      end

      def find_by_id(type, id, options={})
        id = id.to_mongo_id if id.is_a? String
        to_entity(type, @db.find_by_id(type, id), options)
      end

      def to_entity(type, mongo_doc, options={})
        depth = options[:depth] || 1
        return nil if depth < 0

        obj = @config.build_object_of_type(type)
        obj.instance_eval {
          @id = mongo_doc.mongo_id
          def id
            @id
          end
        }
        map = @config.maps[type]

        map.properties.each do |name, prop|
          case prop.mode
          when Monger::Config::PropertyModes::Direct
            obj.set_property(name, mongo_doc[name.to_s])
          when Monger::Config::PropertyModes::Reference
            doc = @db.find_by_id(prop.type, mongo_doc["#{name}_id"])
            obj.set_property(name, self.to_entity(prop.type, doc, :depth => depth-1))
          when Monger::Config::PropertyModes::Collection
            coll = []
            
            ref_prop = @config.maps[prop.type].properties.values.find {|p| 
              p.mode == Monger::Config::PropertyModes::Reference && p.type == type
            }
            ref_prop_name = ref_prop.nil? ? type.to_s : ref_prop.name

            docs = @db.find(prop.type, {"#{ref_prop_name}_id" => mongo_doc.mongo_id})
            docs.each do |doc|
              mapped = self.to_entity(prop.type, doc, :depth => depth-1) 
              coll << mapped unless mapped.nil?
            end
            obj.set_property(name, coll)
          end
        end
        return obj
      end

      def from_entity(type, entity)
        doc = {}

      end
    end
  end
end