%w(class_names object_properties mongo_ids).each do |patch|
  require "monger/patches/#{patch}"
end