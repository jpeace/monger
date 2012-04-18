require 'mongo'

module Monger
  module Mongo
    class Database
      def initialize(config)
        @db = ::Mongo::Connection.new(config.host, config.port).db(config.database)
      end

      def find_all(type)
        @db[type.to_s].find
      end

      def find_by_id(type, id)
        @db[type.to_s].find({'_id' => id}).first
      end

      def find(type, criteria={})
        @db[type.to_s].find(criteria)
      end

      def insert(type, doc, options={})
        @db[type.to_s].insert(doc)
        @db.get_last_error
      end

      def update(type, doc, options={})
        @db[type.to_s].update({'_id'=>doc.monger_id}, doc)
        @db.get_last_error if options[:atomic]
      end
    end
  end
end