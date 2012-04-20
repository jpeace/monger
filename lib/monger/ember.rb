%w(mapper).each do |dep|
  require "monger/ember/#{dep}"
end