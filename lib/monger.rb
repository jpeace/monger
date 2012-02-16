require 'monger/context'
require 'monger/patches'
require 'monger/version'

module Monger
  
  class << self
    def context
      @context
    end

    def bootstrap(config_folder='config/monger')
      config = Configuration.new("#{Dir.pwd}/#{config_folder}/config.rb")
      @context = Context.new
    end
  end

end