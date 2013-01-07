module Monger
  module Mongo
    module Placeholders
      class LazyReferencePlaceholder

        def initialize(api, parent, prop, id)
          @api = api
          @id = id
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          entity = @api.find_by_id(@prop.type, @id)
          @parent.send("#{@prop.name}=", entity)
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end

      end
    end
  end
end
