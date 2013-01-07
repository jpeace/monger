module Monger
  module Mongo
    module Placeholders
      class LazyCollectionPlaceholder

        def initialize(api, entity_type, parent, prop, index, prop_value)
          @api = api
          @entity_type = entity_type
          @id = prop_value
          @parent = parent
          @prop = prop
          @index = index
        end

        def method_missing(method, *args, &block)
          entity = @api.find_by_id(@entity_type, @id)
          @parent.method(@prop).call.send("[]=", @index, entity)
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end

      end
    end
  end
end
