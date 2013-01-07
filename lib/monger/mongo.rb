%w(database mapper api).each do |dep|
  require "monger/mongo/#{dep}"
end

%w(lazy_reference_placeholder lazy_collection_placeholder eager_collection_placeholder).each do |dep|
  require "monger/mongo/placeholders/#{dep}"
end