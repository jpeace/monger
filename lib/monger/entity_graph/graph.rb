module Monger
  module EntityGraph
    class Graph

      attr_reader :nodes, :edges

      def initialize
        @nodes = [ ]
        @edges = [ ]
      end

      def add_node(entity)
        @nodes << entity
      end

      def add_edge(from_entity, to_entity)
        @edges << { :from => from_entity, :to => to_entity }
      end

      def add_subgraph(subgraph)
        subgraph.nodes.each do |node|
          add_node node unless @nodes.include? node
        end

        subgraph.edges.each do |edge|
          add_edge(edge[:from], edge[:to]) unless @edges.include? edge
        end
      end

      def topo_sort
        node_list = [ ]
        @nodes.each do |node|
          active_edges = @edges.select {|edge| edge[:from] == node or edge[:to] == node}
          node_index = 0
          active_edges.each do |edge|
            if edge[:from] == node
              to_index = node_list.find_index edge[:to]
              if not to_index.nil? and not to_index == 0 and to_index < node_index
                node_index = to_index - 1
              end
            else
              from_index = node_list.find_index edge[:from]
              if not from_index.nil? and from_index > node_index
                node_index = from_index + 1
              end
            end
          end
          node_list.insert(node_index, node)
        end
        node_list
      end
    end
  end
end
