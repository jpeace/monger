%w(class_names object_properties monger_ids).each do |patch|
  require "monger/patches/#{patch}"
end