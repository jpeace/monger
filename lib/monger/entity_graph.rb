%w(graph graph_builder).each do |dep|
  require "monger/entity_graph/#{dep}"
end