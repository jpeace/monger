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

      def find_by_id(type, id)
        id = id.to_mongo_id if id.is_a? String
        to_entity(type, @db.find_by_id(type, id))
      end

      def to_entity(type, mongo_doc, options={})
        obj = @config.build_object_of_type(type)
        map = @config.maps[type]

        map.properties.each do |name, prop|
          case prop.mode
          when Monger::Config::PropertyModes::Direct
            obj.set_property(name, mongo_doc[name.to_s])
          when Monger::Config::PropertyModes::Reference
            doc = @db.find_by_id(prop.type, mongo_doc["#{name}_id"])
            obj.set_property(name, self.to_entity(prop.type, doc))
          when Monger::Config::PropertyModes::Collection
            coll = []
            docs = @db.find(prop.type, {"#{type}_id" => mongo_doc.mongo_id})
            docs.each do |doc|
              coll << self.to_entity(prop.type, doc)
            end
            obj.set_property(name, coll)
          end
        end
        return obj
      end

      def from_entity(type, entity)
      end
    end
  end
end