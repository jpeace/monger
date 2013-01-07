module Monger
  module Mongo
    module Placeholders
      class EagerCollectionPlaceholder

        def initialize(api, entity_type, parent, prop, prop_value)
          @api = api
          @entity_type = entity_type
          @ids = prop_value
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          criteria = { :$or => [] }
          @ids.each do |id|
            criteria[:$or] << { :_id => id }
          end
          entity_list = @api.find(@entity_type, criteria)
          @parent.send("#{@prop}=", entity_list )
          args.empty? ? parent_property.send(method, &block) : parent_property.send(method, *args, &block)
        end

        def parent_property
          @parent.method(@prop).call
        end

      end
    end
  end
end
