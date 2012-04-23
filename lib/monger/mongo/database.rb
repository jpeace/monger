require 'mongo'

module Monger
  module Mongo
    class Database
      def initialize(config)
        @config = config
        @db = ::Mongo::Connection.new(@config.host, @config.port).db(@config.database)
      end

      def find(type, criteria={})
        if @config.verbose?
          puts type.inspect
          puts criteria.inspect
        end
        @db[type.to_s].find(criteria)
      end

      def find_all(type)
        find(type)
      end

      def find_by_id(type, id)
        find(type, {'_id' => id}).first
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