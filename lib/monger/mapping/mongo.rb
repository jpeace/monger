require 'mongo'

module Monger
  module Mapping
    class Mongo
      class Database
        def initialize(config)
          @db = Mongo::Connection.new(config.host, config.port).db(config.database)
        end

        def find_all(type)
          @db[type.to_s].find
        end

        def find_with_id(type, id)
          #bson_id = BSON::ObjectId(id)
          @db[type.to_s].find({'_id' => id}).first
        end
      end
      
      def initialize(config)
        @config = config
        @db = Database.new(config)
      end

      def to_entity(type, mongo_doc)
        obj = config.build_object_of_type(type)
        map = config.maps[type]
        map.properties.each do |p|
          case p.mode
          when Monger::Config::PropertyModes::Direct
            obj.set_property(p.name, mongo_doc[p.name])
          when Monger::Config::PropertyModes::Reference
            doc = @db.find_with_id(p.type, mongo_doc["#{p.name}_id"])
            obj.set_property(p.name, self.to_entity(p.type, doc))
          when Monger::Config::PropertyModes::Collection
          end
        end
      end

      def from_entity(type, entity)
      end
    end
  end
end