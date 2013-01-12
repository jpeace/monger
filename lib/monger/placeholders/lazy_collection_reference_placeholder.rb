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
        if entity.nil?
          array_property.delete_at index
          args.empty? ? array_property[index].send(method, &block) : array_property[index].send(method, *args, &block) unless array_property.length-1 < index
        else
          array_property[index] = entity
          args.empty? ? entity.send(method, &block) : entity.send(method, *args, &block)
        end
      end

    end
  end
end
