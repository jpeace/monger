%w(database mapper api).each do |dep|
  require "monger/mongo/#{dep}"
end