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
        @config.mongo_hooks[:before_read].each {|proc| proc.call(type, criteria)}
        @db[type.to_s].find(criteria)
      end

      def insert(type, doc, options={})
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)}
        @db[type.to_s].insert(doc)
        @db.get_last_error
      end

      def update(type, doc, options={})
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)}
        @db[type.to_s].update({'_id'=>doc.monger_id}, doc)
        @db.get_last_error if options[:atomic]
      end

      def delete(type, criteria, options={})
        @db[type.to_s].remove(criteria)
        @db.get_last_error if options[:atomic]
      end
    end
  end
end