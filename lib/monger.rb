require 'monger/patches'
require 'monger/config'
require 'monger/session'
require 'monger/mongo'
require 'monger/version'

module Monger
  class << self
    def bootstrap(config_file='config/monger.rb')
      Configuration.new("#{Dir.pwd}/#{config_file}")
    end

    def create_session(config)
      Session.new(config)
    end
  end
end