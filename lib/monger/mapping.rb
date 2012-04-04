%w(json mongo).each do |mapper|
  require "monger/mapping/#{mapper}"
end

module Monger
  class Mapper
    attr_reader :entity, :json, :mongo_doc

    def initialize(config)
      @config = config

      @json = Monger::Mapping::Json.new(@config)
      @mongo = Monger::Mapping::Mongo.new(@config)
    end
  end
end