module Monger
  class Context
    def initialize(config)
      @db = Mongo::Connection.new(config.host, config.port).db(config.database)
    end
  end
end