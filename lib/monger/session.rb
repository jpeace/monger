module Monger
  class Session
    def initialize(config)
      @config = config

      mongo_db = ::Monger::Mongo::Database.new(config)
      @mongo_api = Monger::Mongo::Api.new(config, mongo_db)

      @ember_mapper = Monger::Ember::Mapper.new(config)
      @json_mapper = Monger::Json::Mapper.new(config)
    end

    def mongo
      @mongo_api
    end

    def ember
      @ember_mapper
    end

    def json
      @json_mapper
    end
  end
end