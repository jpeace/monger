module Monger
  module Mongo
    module Placeholders
      # this class lazy loads a reference
      class LazyReferencePlaceholder

        def monger_id
          @id
        end

        def initialize(api, parent, prop, id)
          @api = api
          @id = id
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          entity = @api.find_by_id(@prop.type, @id)
          @parent.set_property(@prop.name, entity)
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end

      end
    end
  end
end
