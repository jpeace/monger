module Monger
  class Session
    def initialize(config)
      @config = config
      @mongo_mapper = Monger::Mongo::Mapper.new(@config)
      @ember_mapper = Monger::Ember::Mapper.new(@config)
      @json_mapper = Monger::Json::Mapper.new(@config)
    end

    def mongo
      @mongo_mapper
    end

    def ember
      @ember_mapper
    end

    def json
      @json_mapper
    end
  end
end