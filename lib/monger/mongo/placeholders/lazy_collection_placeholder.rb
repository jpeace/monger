module Monger
  module Mongo
    module Placeholders
      class LazyCollectionPlaceholder

        def initialize(api, parent, prop, index, id)
          @api = api
          @parent = parent
          @prop = prop
          @index = index
          @id = id
        end

        def method_missing(method, *args, &block)
          entity = @api.find_by_id(@prop.type, @id)
          @parent.method(@prop.name).call.send("[]=", @index, entity)
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end

      end
    end
  end
end
