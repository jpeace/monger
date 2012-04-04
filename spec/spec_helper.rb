def environment_root
  "#{File.dirname(__FILE__)}/environment"
end

require 'monger'
require_relative 'environment/domain'
require_relative 'environment/mocks'
require_relative 'environment/database'