module Monger
  module Mongo
    module Placeholders
      class LazyReferencePlaceholder

        def initialize(api, entity_type, parent, prop, prop_value)
          @api = api
          @entity_type = entity_type
          @id = prop_value
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          entity = @api.find_by_id(@entity_type, @id)
          @parent.send("#@prop=", entity)
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end

      end
    end
  end
end
