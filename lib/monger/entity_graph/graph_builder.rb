module Monger
  module EntityGraph
    class GraphBuilder

      def initialize(config)
        @config = config
      end

      # TODO: remove is_placeholder? from all these classes, and put placeholder features in a single manager
      def create_graph(entity)
        type = entity.class.build_symbol
        map = @config.maps[type]

        graph = ::Monger::EntityGraph::Graph.new
        graph.add_node entity

        map.reference_properties.each do |name, prop|
          reference = entity.get_property(name)
          next if reference.nil? or is_placeholder? reference

          graph.add_subgraph create_graph(reference)
          graph.add_edge(entity, reference)
        end

        map.collection_properties.each do |name, prop|
          reference_list = entity.get_property(name)
          next if reference_list.nil? or is_placeholder? reference_list

          reference_list.each do |reference|
            next if reference.nil? or is_placeholder? reference

            graph.add_subgraph create_graph(reference)
            if prop.inverse?
              graph.add_edge(entity, reference)
            else
              graph.add_edge(reference, entity)
            end
          end
        end

        graph
      end

      private

      def is_placeholder?(entity)
        [
            Placeholders::LazyReferencePlaceholder,
            Placeholders::LazyCollectionReferencePlaceholder,
            Placeholders::LazyMappedCollectionPlaceholder,
            Placeholders::EagerInverseCollectionPlaceholder,
            Placeholders::EagerMappedCollectionPlaceholder
        ].include?(entity.class)
      end

    end
  end
end