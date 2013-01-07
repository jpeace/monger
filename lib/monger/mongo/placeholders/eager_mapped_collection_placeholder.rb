module Monger
  module Mongo
    module Placeholders
      class EagerMappedCollectionPlaceholder

        def initialize(api, parent, prop)
          @api = api
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          entity_list = @api.find(@prop.type, { "#{@prop.ref_name}_id" => @parent.monger_id })
          @parent.send("#{@prop.name}=", entity_list )
          args.empty? ? parent_property.send(method, &block) : parent_property.send(method, *args, &block)
        end

        def parent_property
          @parent.method(@prop.name).call
        end

      end
    end
  end
end
