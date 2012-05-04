require 'mongo'

module Monger
  module Mongo
    class Database
      def initialize(config)
        @config = config
        @db = ::Mongo::Connection.new(@config.host, @config.port).db(@config.database)
      end

      def find(type, criteria={}, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_read].each {|proc| proc.call(type, criteria)} unless skip_hooks
        puts "Mongo Find: #{type.inspect} #{criteria.inspect}" if @config.verbose?
 
        @db[type.to_s].find(criteria)
      end

      def insert(type, doc, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)} unless skip_hooks
        puts "Mongo Insert: #{type.inspect} #{doc.inspect}" if @config.verbose?

        @db[type.to_s].insert(doc)
        @db.get_last_error
      end

      def update(type, doc, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)} unless skip_hooks
        puts "Mongo Update: #{type.inspect} #{doc.inspect}" if @config.verbose?

        @db[type.to_s].update({'_id'=>doc.monger_id}, doc)
        @db.get_last_error if options[:atomic]
      end

      def delete(type, criteria, options={})
        puts "Mongo Delete: #{type.inspect} #{criteria.inspect}" if @config.verbose?

        @db[type.to_s].remove(criteria)
        @db.get_last_error if options[:atomic]
      end
    end
  end
end