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
                  reference_entity = ::Monger::Placeholders::LazyReferencePlaceholder.new(@api, entity, prop, reference_id) unless reference_id.nil?
                end
              end

              entity.set_property(name, reference_entity)

            when :collection
              collection = [ ]

              if prop.inline?
                reference_docs = doc[name.to_s]
                collection = docs_to_entities(@api.config.maps[prop.type], reference_docs, options) unless reference_docs.nil?
              else
                if prop.eager?
                  if prop.inverse?
                    reference_ids = doc[name.to_s] || [ ]
                    collection = ::Monger::Placeholders::EagerInverseCollectionPlaceholder.new(@api, entity, prop, reference_ids)
                  else
                    collection = ::Monger::Placeholders::EagerMappedCollectionPlaceholder.new(@api, entity, prop)
                  end
                else
                  if prop.inverse?
                    reference_ids = doc[name.to_s] || [ ]
                    collection = reference_ids.map{|id| ::Monger::Placeholders::LazyCollectionReferencePlaceholder.new(@api, entity, prop, id)} if reference_ids.class == Array
                  else
                    # for a lazy loaded mapped collection, the doc[name.to_s] is a cursor prebuilt in the api request
                    cursor = doc[name.to_s]
                    collection = ::Monger::Placeholders::LazyMappedCollectionPlaceholder.new(@api, entity, prop, cursor)
                  end
                end
              end

              entity.set_property(name, collection)
          end
        end

        entity
      end

      def docs_to_entities(map, docs, options={})
        collection = [ ]

        docs.each do |doc|
          collection << doc_to_entity(map, doc, options) unless doc.nil?
        end

        collection
      end

      # TODO: remove is_placeholder? from all these classes, and put placeholder features in a single manager
      def entity_to_doc(map, entity, options={})
        doc = {}

        doc.monger_id = entity.monger_id if options[:inline].nil?
        map.properties.each do |name, prop|
          value = entity.get_property(name)
          next if value.nil?

          case prop.mode
            when :direct, :date
              doc[name.to_s] = value

            when :time
              doc[name.to_s] = { 'hour' => value.hour, 'minute' => value.minute, 'second' => value.second }

            when :reference
              if prop.inline?
                doc[name.to_s] = entity_to_doc(@api.config.maps[prop.type], value, { :inline => true })
              else
                doc["#{name.to_s}_id"] = value.monger_id
              end

            when :collection
              if prop.inline?
                collection_entity_map = @api.config.maps[prop.type]
                doc[name.to_s] = value.map {|collection_entity| entity_to_doc(collection_entity_map, collection_entity, { :inline => true })}
              elsif prop.inverse?
                doc[name.to_s] = is_placeholder?(value) ? value.ids : value.map {|collection_entity| collection_entity.monger_id}
              end
          end
        end

        doc
      end
      
      private

      def is_placeholder?(entity)
        [
            Placeholders::LazyReferencePlaceholder,
            Placeholders::LazyCollectionReferencePlaceholder,
            Placeholders::LazyMappedCollectionPlaceholder,
            Placeholders::EagerInverseCollectionPlaceholder,
            Placeholders::EagerMappedCollectionPlaceholder
        ].include?(entity.class)
      end

    end  
  end
end
