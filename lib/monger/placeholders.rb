%w(
lazy_reference_placeholder
lazy_collection_reference_placeholder
lazy_mapped_collection_placeholder
eager_inverse_collection_placeholder
eager_mapped_collection_placeholder
).each do |dep|
  require "monger/placeholders/#{dep}"
end