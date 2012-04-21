%w(mapper).each do |dep|
  require "monger/json/#{dep}"
end