module Monger
  module Placeholders
    # this class lazy loads a reference into a collection
    class LazyCollectionReferencePlaceholder

      def monger_id
        @id
      end

      def initialize(api, parent, prop, id)
        @api = api
        @parent = parent
        @prop = prop
        @id = id
      end

      def method_missing(method, *args, &block)
        entity = @api.find_by_id(@prop.type, @id)
        array_property = @parent.get_property(@prop.name)
        index = array_property.find_index self
        array_property[index] = entity
        array_property.compact!
        args.empty? ? array_property[index].send(method, &block) : array_property[index].send(method, *args, &block) unless array_property.length-1 < index
      end

    end
  end
end
