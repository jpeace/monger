%w(database mapper).each do |dep|
  require "monger/mongo/#{dep}"
end