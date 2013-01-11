module Monger
  module Placeholders
    # this class eager loads all references of a mapped collection on access
    class EagerMappedCollectionPlaceholder

      def initialize(api, parent, prop)
        @api = api
        @parent = parent
        @prop = prop
      end

      def method_missing(method, *args, &block)
        entity_list = @api.find(@prop.type, { "#{@prop.ref_name}_id" => @parent.monger_id })
        @parent.set_property(@prop.name, entity_list)
        args.empty? ? entity_list.send(method, &block) : entity_list.send(method, *args, &block)
      end

    end
  end
end