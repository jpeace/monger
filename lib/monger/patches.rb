%w(class_names object_properties).each do |patch|
  require "monger/patches/#{patch}"
end