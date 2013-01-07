module Monger
  module Mongo
    class Api

      def initialize(config, db)
        @config = config
        @db = db
        @mapper = ::Monger::Mongo::Mapper.new(self)
      end

      def find(type, criteria, options={})
        docs = @db.find(type, criteria, options).map {|doc| @mapper.doc_to_entity(type, doc, options)}
        entities = docs.map {|doc| @mapper.doc_to_entity(@config.maps[type], doc, options)}

      end

      def find_all(type, options={})
        find(type, {}, options)
      end

      def find_one(type, criteria, options={})
        options.merge!({:limit => 1})
        doc = @db.find(type, criteria, options).first
        map = @config.maps[type]
        @mapper.doc_to_entity(map, doc, options)
      end

      def find_by_id(type, id, options={})
        begin
          id = id.to_monger_id if id.is_a? String
          find_one(type, { :_id => id }, options)
        rescue BSON::InvalidObjectId
          return nil
        end
      end

      def search(type, term, options={})
        find(type, build_search_criteria(type, term, options[:fields]), options)
      end

      def delete(type, id, options={})
        id = id.to_monger_id if id.is_a? String
        remove_entity(find_by_id(type, id), options)
      end

      def remove_entity(entity, options={})
        if entity.respond_to? :monger_id
          type = entity.class.build_symbol
          id = entity.monger_id

          remove_references(entity)
          remove_collections(type, id)
          @db.delete(type, { :_id => id }, options)
        end
      end

      def save(entity, options={})
        inline = options[:inline] || false
        skip_hooks = options[:skip_hooks] || false

        type = entity.class.build_symbol

        doc = @mapper.entity_to_doc entity

        if !inline
          if entity.monger_id.nil?
            @db.insert(type, doc, options)
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
            when :direct, :date
              doc[name.to_s] = value
            when :time
              doc[name.to_s] = {'hour' => value.hour, 'minute' => value.minute, 'second' => value.second}
            when :reference
              if prop.inline?
                doc[name.to_s] = save(value, :inline => true, :skip_hooks => skip_hooks)
              else
                save(value, :skip_hooks => skip_hooks) if value.monger_id.nil? || prop.update?
                doc["#{name}_id"] = value.monger_id
              end
            when :collection
              value.each do |el|
                if prop.inline?
                  doc[name.to_s] ||= []
                  doc[name.to_s] << save(el, :inline => true, :skip_hooks => skip_hooks)
                elsif prop.inverse?
                  doc[name.to_s] ||= []
                  save(el, :skip_hooks => skip_hooks) if el.monger_id.nil?
                  doc[name.to_s] << el.monger_id if el.respond_to? :monger_id
                else
                  if el.monger_id.nil? || prop.update?
                    save(el, :extra => {"#{prop.ref_name}_id" => entity.monger_id}, :skip_hooks => skip_hooks)
                  end
                end
              end
          end
        end

        extra = options[:extra] || {}
        extra.each do |k,v|
          doc[k] = v
        end

        @db.update(type, doc, options) unless inline
        return doc
      end

      private

      def remove_references(entity)
        return if entity.nil?

        type = entity.class.build_symbol
        map = @config.maps[type]
        map.reference_properties.each do |name, prop|
          if prop.delete?
            val = entity.get_property(name)
            delete(prop.type, val.monger_id) unless val.nil?
          end
        end
      end

      def remove_collections(type, id)
        map = @config.maps[type]
        return if map.nil?

        map.collection_properties.each do |name, prop|
          if prop.delete?
            collection = find(prop.type, {"#{prop.ref_name}_id" => id})
            collection.each {|i| delete(prop.type, i.monger_id)}
          end
        end
      end

      public

      def build_search_criteria(type, term, fields=nil)
        criteria = {}
        map = @config.maps[type]
        fields = map.direct_properties.map{|name,prop| name} if fields.nil?
        criteria['$or'] = fields.map {|name| {name.to_s => /#{term}/i}}
        criteria
      end
    end
  end
end