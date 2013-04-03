require 'mongo'

module Monger
  module Mongo
    class Database
      include ::Mongo

      def initialize(config)
        @config = config
      end

      def client
        if @client.nil? || !@client.active?
          puts "BUILDING CONNECTION"
          @client = MongoClient.new(@config.host, @config.port, :pool_size => 25, :pool_timeout => 5)
        end
        @client
      end

      def db
        client.db(@config.database)
      end

      def count(type, criteria={})
        db[type.to_s].count(:query => criteria)
      end

      def find(type, criteria={}, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_read].each {|proc| proc.call(type, criteria)} unless skip_hooks
        puts "Mongo Find: #{type.inspect} #{criteria.inspect}" if @config.verbose?
 
        mongo_options = {}
        cursor = db[type.to_s].find(criteria, mongo_options)
        unless options[:limit].nil? || !options[:limit].is_a?(Fixnum)
          cursor.limit(options[:limit])
        end
        return cursor
      end

      def insert(type, doc, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)} unless skip_hooks
        puts "Mongo Insert: #{type.inspect} #{doc.inspect}" if @config.verbose?

        db[type.to_s].insert(doc)
        db.get_last_error
      end

      def update(type, doc, options={})
        skip_hooks = options[:skip_hooks] || false
        @config.mongo_hooks[:before_write].each {|proc| proc.call(type, doc)} unless skip_hooks
        puts "Mongo Update: #{type.inspect} #{doc.inspect}" if @config.verbose?

        # $set operator does not work when an id is passed
        id = doc.monger_id
        doc.delete(:_id)
        doc.delete('_id')
        
        db[type.to_s].update({'_id'=>id}, {'$set' => doc})
        db.get_last_error if options[:atomic]
      end

      def delete(type, criteria, options={})
        puts "Mongo Delete: #{type.inspect} #{criteria.inspect}" if @config.verbose?

        db[type.to_s].remove(criteria)
        db.get_last_error if options[:atomic]
      end
    end
  end
end