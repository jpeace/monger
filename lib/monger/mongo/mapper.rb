module Monger
  module Mongo
    class Mapper
      def initialize(config)
        @config = config
        @db = Database.new(config)
      end

      def find_all(type, options={})
        @db.find_all(type).map {|doc| doc_to_entity(type, doc, options)}
      end

      def find_by_id(type, id, options={})
        id = id.to_monger_id if id.is_a? String
        doc_to_entity(type, @db.find_by_id(type, id), options)
      end

      def find(type, criteria, options={})
        @db.find(type, criteria).map {|doc| doc_to_entity(type, doc, options)}
      end

      def save(entity, options={})
        type = entity.class.build_symbol

        doc = {}
        if entity.monger_id.nil?
          @db.insert(type, doc)
          entity.monger_id = doc.monger_id
        else
          doc.monger_id = entity.monger_id
        end
        
        map = @config.maps[type]
        map.properties.each do |name, prop|
          value = entity.get_property(name)
          next if value.nil?

          case prop.mode
          when Monger::Config::PropertyModes::Direct
            doc[name.to_s] = value
          when Monger::Config::PropertyModes::Reference
            save(value) if value.monger_id.nil? || prop.update?
            doc["#{name}_id"] = value.monger_id
          when Monger::Config::PropertyModes::Collection
            value.each do |el|
              if el.monger_id.nil? || prop.update?
                save(el, :extra => {"#{prop.ref_name}_id" => entity.monger_id})
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

      def doc_to_entity(type, mongo_doc, options={})
        depth = options[:depth] || 1
        return nil if depth < 0

        obj = @config.build_object_of_type(type)
        obj.monger_id = mongo_doc.monger_id
        
        map = @config.maps[type]

        map.properties.each do |name, prop|
          case prop.mode
          when Monger::Config::PropertyModes::Direct
            obj.set_property(name, mongo_doc[name.to_s])
          when Monger::Config::PropertyModes::Reference
            doc = @db.find_by_id(prop.type, mongo_doc["#{name}_id"])
            obj.set_property(name, doc_to_entity(prop.type, doc, :depth => depth-1))
          when Monger::Config::PropertyModes::Collection
            coll = []
            
            docs = @db.find(prop.type, {"#{prop.ref_name}_id" => mongo_doc.monger_id})
            docs.each do |doc|
              mapped = doc_to_entity(prop.type, doc, :depth => depth-1) 
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