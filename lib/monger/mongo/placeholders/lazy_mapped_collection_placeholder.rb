module Monger
  module Mongo
    module Placeholders
      # this class lazy loads items into a mapped collection by deferring the mongo cursor hydration until an index is requested
      class LazyMappedCollectionPlaceholder

        def monger_id
          @id
        end

        def initialize(api, parent, prop, cursor)
          @api = api
          @parent = parent
          @prop = prop
          @cursor = cursor
        end

        def method_missing(method, *args, &block)
          ids = @cursor.to_a.map {|doc| doc['_id']}
          entity_list = ids.each_with_index.map {|id, index| LazyCollectionReferencePlaceholder.new(@api, @parent, @prop, index, id)}
          @parent.set_property(@prop.name, entity_list)
          args.empty? ? entity_list.send(method, &block) : entity_list.send(method, *args, &block)
        end

      end
    end
  end
end
