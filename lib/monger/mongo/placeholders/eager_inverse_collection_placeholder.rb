module Monger
  module Mongo
    module Placeholders
      class EagerInverseCollectionPlaceholder

        attr_reader :ids

        def initialize(api, parent, prop, ids)
          @api = api
          @ids = ids
          @parent = parent
          @prop = prop
        end

        def method_missing(method, *args, &block)
          criteria = { :$or => [] }
          @ids.each do |id|
            criteria[:$or] << { :_id => id }
          end
          entity_list = @api.find(@prop.type, criteria)
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
