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

        def insert(type, doc, options={})
          @db[type.to_s].insert(doc)
          @db.get_last_error
        end

        def update(type, doc, options={})
          @db[type.to_s].update({'_id'=>doc.mongo_id}, doc)
          @db.get_last_error if options[:atomic]
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

      def save(type, entity, options={})
        doc = {}
        if entity.mongo_id.nil?
          @db.insert(type, doc)
          entity.mongo_id = doc.mongo_id
        else
          doc.mongo_id = entity.mongo_id
        end
        
        map = @config.maps[type]
        map.properties.each do |name, prop|
          value = entity.get_property(name)
          next if value.nil?

          case prop.mode
          when Monger::Config::PropertyModes::Direct
            doc[name.to_s] = value
          when Monger::Config::PropertyModes::Reference
            self.save(prop.type, value) if value.mongo_id.nil?
            doc["#{name}_id"] = value.mongo_id
          when Monger::Config::PropertyModes::Collection
            value.each do |el|
              if el.mongo_id.nil?
                self.save(prop.type, el, :extra => {"#{prop.ref_name}_id" => entity.mongo_id})
              end
            end
          end  
        end

        extra = options[:extra] || {}
        extra.each do |k,v|
          doc[k] = v
        end

        @db.update(type, doc, :atomic => options[:atomic])
        return doc
      end

      def to_entity(type, mongo_doc, options={})
        depth = options[:depth] || 1
        return nil if depth < 0

        obj = @config.build_object_of_type(type)
        obj.mongo_id = mongo_doc.mongo_id
        
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
            
            # ref_prop = @config.maps[prop.type].properties.values.find {|p| 
            #   p.mode == Monger::Config::PropertyModes::Reference && p.type == type
            # }
            # ref_prop_name = ref_prop.nil? ? type.to_s : ref_prop.name

            docs = @db.find(prop.type, {"#{prop.ref_name}_id" => mongo_doc.mongo_id})
            docs.each do |doc|
              mapped = self.to_entity(prop.type, doc, :depth => depth-1) 
              coll << mapped unless mapped.nil?
            end
            obj.set_property(name, coll)
          end
        end
        return obj
      end
    end
  end
end