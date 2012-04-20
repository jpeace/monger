%w(code_gen_binding mapper).each do |dep|
  require "monger/ember/#{dep}"
end