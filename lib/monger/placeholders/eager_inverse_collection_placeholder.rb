module Monger
  module Placeholders
    # this class eager loads all references of an inverse collection on access
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
        @parent.set_property(@prop.name, entity_list)
        args.empty? ? entity_list.send(method, &block) : entity_list.send(method, *args, &block)
      end

    end
  end
end