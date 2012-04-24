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

      def search(type, term, options={})
        find(type, build_search_criteria(type, term, options[:fields]), options)
      end

      def build_search_criteria(type, term, fields=nil)
        criteria = {}
        map = @config.maps[type]
        fields = map.direct_properties.map{|name,prop| name} if fields.nil?
        criteria['$or'] = fields.map {|name| {name.to_s => /#{term}/i}}
        criteria
      end

      def save(entity, options={})
        inline = options[:inline] || false

        type = entity.class.build_symbol

        doc = {}

        if !inline
          if entity.monger_id.nil?
            @db.insert(type, doc)
            entity.monger_id = doc.monger_id
          else
            doc.monger_id = entity.monger_id
          end
        end

        map = @config.maps[type]
        map.properties.each do |name, prop|
          value = entity.get_property(name)
          next if value.nil?

          case prop.mode
          when :direct
            doc[name.to_s] = value
          when :reference
            if prop.inline?
              doc[name.to_s] = save(value, :inline => true)
            else
              save(value) if value.monger_id.nil? || prop.update?
              doc["#{name}_id"] = value.monger_id
            end
          when :collection
            value.each do |el|
              if prop.inline?
                doc[name.to_s] ||= []
                doc[name.to_s] << save(el, :inline => true)
              else
                if el.monger_id.nil? || prop.update?
                  save(el, :extra => {"#{prop.ref_name}_id" => entity.monger_id})
                end
              end
            end
          end  
        end

        extra = options[:extra] || {}
        extra.each do |k,v|
          doc[k] = v
        end

        @db.update(type, doc, :atomic => options[:atomic]) unless inline
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
          when :direct
            obj.set_property(name, mongo_doc[name.to_s])
          when :reference
            if prop.inline?
              doc = mongo_doc[name.to_s]
            else
              doc = @db.find_by_id(prop.type, mongo_doc["#{name}_id"])
            end
            obj.set_property(name, doc_to_entity(prop.type, doc, :depth => depth-1)) unless doc.nil?
          when :collection
            coll = []
            
            if prop.inline?
              docs = mongo_doc[name.to_s]
            else
              docs = @db.find(prop.type, {"#{prop.ref_name}_id" => mongo_doc.monger_id})
            end

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