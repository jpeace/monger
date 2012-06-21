module Monger
  module Mongo
    class Mapper
      def initialize(config)
        @config = config
        @db = Database.new(config)
      end

      def find(type, criteria, options={})
        @db.find(type, criteria, options).map {|doc| doc_to_entity(type, doc, options)}
      end

      def find_all(type, options={})
        find(type, {}, options)
      end

      def find_one(type, criteria, options={})
        find(type, criteria, options).first
      end

      def find_by_id(type, id, options={})
        id = id.to_monger_id if id.is_a? String
        find(type, {'_id' => id}, options).first
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
          @db.delete(type, {'_id' => id}, options)
        end
      end

      def save(entity, options={})
        inline = options[:inline] || false

        type = entity.class.build_symbol

        doc = {}

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
              elsif prop.inverse?
                doc[name.to_s] ||= []
                save(el) if el.monger_id.nil?
                doc[name.to_s] << el.monger_id if el.respond_to? :monger_id
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

      def doc_to_entity(type, mongo_doc, options={})
        depth = options[:depth] || 1
        ignore = options[:ignore] || []

        obj = @config.build_object_of_type(type)
        obj.monger_id = mongo_doc.monger_id
        
        map = @config.maps[type]

        new_depth = depth - 1

        map.properties.each do |name, prop|
          next if ignore.include? name

          if depth <= 0 && [:reference, :collection].include?(prop.mode)
            unless (prop.inline? || prop.always_read?)
              obj.set_property(name, []) if prop.mode == :collection
              next
            end
          end
          
          case prop.mode
          when :direct, :date
            obj.set_property(name, mongo_doc[name.to_s])
          when :time
            time_obj = mongo_doc[name.to_s]
            obj.set_property(name, TimeOfDay.new(time_obj['hour'], time_obj['minute'], time_obj['second'])) unless time_obj.nil?
          when :reference
            if prop.inline?
              doc = mongo_doc[name.to_s]
            else
              ref_id = mongo_doc["#{name}_id"]
              if ref_id.nil?
                doc = nil
              else
                doc = @db.find(prop.type, {'_id' => ref_id}, options).first
              end
            end
            obj.set_property(name, doc_to_entity(prop.type, doc, :depth => new_depth, :ignore => ignore, :skip_hooks => options[:skip_hooks])) unless doc.nil?
          when :collection
            coll = []
            
            if prop.inline?
              docs = mongo_doc[name.to_s]
            elsif prop.inverse?
              ids = mongo_doc[name.to_s]
              unless ids.nil?
                # Preserve order of collection
                docs = []
                tmp_docs = @db.find(prop.type, {'_id' => {'$in' => ids}}, options).to_a

                ids.each do |id|
                  docs << tmp_docs.select {|doc| doc['_id'] == id}.first
                end
              end
            else
              docs = @db.find(prop.type, {"#{prop.ref_name}_id" => mongo_doc.monger_id}, options)
            end
            docs ||= []

            docs = docs.select {|doc| !doc.nil?}

            docs.each do |doc|
              mapped = doc_to_entity(prop.type, doc, :depth => new_depth, :ignore => ignore, :skip_hooks => options[:skip_hooks]) 
              coll << mapped unless mapped.nil?
            end
            obj.set_property(name, coll)
          end
        end
        return obj
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