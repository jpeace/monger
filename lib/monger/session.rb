module Monger
  class Session
    def initialize(config)
      @config = config
      @mongo_mapper = Monger::Mongo::Mapper.new(@config)
    end

    def mongo
      @mongo_mapper
    end
  end
end