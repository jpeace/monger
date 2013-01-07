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
          prop_value = doc[name.to_s]

          case prop.mode
            when :direct, :date
              entity.set_property(name, prop_value) if doc.has_key?(name.to_s)

            when :time
              entity.set_property(name, ::TimeOfDay.new(prop_value['hour'], prop_value['minute'], prop_value['second'])) unless prop_value.nil?

            when :reference
              reference_entity = nil

              if prop.inline?
                reference_entity = doc_to_entity(@api.config.maps[prop.type], prop_value, options) unless prop_value.nil?
              else
                ref_id = doc["#{name}_id"]
                if prop.eager?
                  reference_entity = @api.find_by_id(prop.type, prop_value, options) unless ref_id.nil?
                else
                  reference_entity = Placeholders::LazyReferencePlaceholder.new(@api, prop.type, entity, name, ref_id) unless ref_id.nil?
                end
              end

              entity.set_property(name, reference_entity)

            when :collection
              collection = []

              if prop.inline?
                collection = docs_to_entities(@api.config.maps[prop.type], prop_value, options)
              else
                unless prop.inverse?
                  puts "#{prop.type}, #{prop.ref_name}_id, #{doc.monger_id.to_s}"
                  prop_value = @api.find(prop.type, { "#{prop.ref_name}_id" => doc.monger_id }, options)
                  puts prop_value
                end

                if prop.eager?
                  collection = Placeholders::EagerCollectionPlaceholder.new(@api, prop.type, entity, name, prop_value)
                else
                  collection = prop_value.each_with_index.map{|id, index| Placeholders::LazyCollectionPlaceholder.new(@api, prop.type, entity, name, index, id)} if prop_value.class == Array
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