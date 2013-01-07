module Monger
  module Mongo
    class Mapper

      # i don't like having api in the mapper, but it seems unavoidable... how to build references without doubling code?
      def initialize(api)
        @api = api
      end

      def doc_to_entity(map, doc, options={})
        return nil if doc.nil?

        # We never want a limit when mapping
        options.delete(:limit)

        entity = map.build_entity
        entity.monger_id = doc.monger_id

        map.properties.each do |name, prop|
          entity.set_property(name, []) if prop.mode == :collection    # Default for collections in case we don't end up mapping

          case prop.mode
            when :direct, :date
              entity.set_property(name, doc[name.to_s]) if doc.has_key?(name.to_s)

            when :time
              time_obj = doc[name.to_s]
              entity.set_property(name, ::TimeOfDay.new(time_obj['hour'], time_obj['minute'], time_obj['second'])) unless time_obj.nil?

            when :reference
              reference_entity = nil

              if prop.inline?
                reference_doc = doc[name.to_s]
                reference_entity = doc_to_entity(@api.config.maps[prop.type], reference_doc, options) unless reference_doc.nil?
              else
                reference_id = doc["#{name}_id"]
                if prop.eager?
                  reference_entity = @api.find_by_id(prop.type, reference_id, options) unless reference_id.nil?
                else
                  reference_entity = Placeholders::LazyReferencePlaceholder.new(@api, entity, prop, reference_id) unless reference_id.nil?
                end
              end

              entity.set_property(name, reference_entity)

            when :collection
              collection = []

              if prop.inline?
                reference_docs = doc[name.to_s]
                collection = docs_to_entities(@api.config.maps[prop.type], reference_docs, options)
              else
                if prop.eager?
                  if prop.inverse?
                    reference_ids = doc[name.to_s]
                    collection = Placeholders::EagerInverseCollectionPlaceholder.new(@api, entity, prop, reference_ids)
                  else
                    collection = Placeholders::EagerMappedCollectionPlaceholder.new(@api, entity, prop)
                  end
                else
                  # in the case of a lazy loaded mapped collection, the reference_ids must be
                  # populated in the api call - this prevents needing database access inside the mapper
                  reference_ids = doc[name.to_s]
                  collection = reference_ids.each_with_index.map{|id, index| Placeholders::LazyCollectionPlaceholder.new(@api, entity, prop, index, id)} if reference_ids.class == Array
                end
              end

              entity.set_property(name, collection)
          end
        end

        entity
      end

      def docs_to_entities(map, docs, options={})
        collection = []

        docs.each do |doc|
          collection << doc_to_entity(map, doc, options) unless doc.nil?
        end

        collection
      end

      def entity_to_doc(map, entity)
        inline = options[:inline] || false
        skip_hooks = options[:skip_hooks] || false

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

    end  
  end
end