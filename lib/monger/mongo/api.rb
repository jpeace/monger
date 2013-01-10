module Monger
  module Mongo
    class Api

      attr_reader :config

      def initialize(config, db)
        @config = config
        @db = db
        @graph_builder = ::Monger::EntityGraph::GraphBuilder.new(config)
        @mapper = ::Monger::Mongo::Mapper.new(self)
      end

      def find(type, criteria, options={})
        cursor_docs = @db.find(type, criteria, options)
        map = @config.maps[type]
        docs = cursor_docs.map {|doc| build_lazy_mapped_collections(map, doc)}
        docs.map {|doc| @mapper.doc_to_entity(map, doc, options)}
      end

      def find_all(type, options={})
        find(type, {}, options)
      end

      def find_one(type, criteria, options={})
        options.merge!({:limit => 1})
        doc = @db.find(type, criteria, options).first
        map = @config.maps[type]
        build_lazy_mapped_collections(map, doc)
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
        type = entity.class.build_symbol
        graph = @graph_builder.create_graph entity
        entity_list = graph.topo_sort.reverse

        entity_list.each do |entity|
          map = @config.maps[entity.class.build_symbol]
          doc = @mapper.entity_to_doc(map, entity)
          if doc.monger_id.nil?
            @db.insert(type, doc, options)
            entity.monger_id = doc.monger_id
          else
            @db.update(type, doc, options)
          end
        end

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

      def build_lazy_mapped_collections(map, doc)
        map.mapped_collection_properties.each do |name, prop|
          if prop.lazy?
            doc[name.to_s] = @db.query[prop.type.to_s].find({ "#{prop.ref_name}_id" => doc['_id'] }, { :fields => %w(_ids) })
          end
        end

        doc
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