require 'mongo'
require 'ostruct'

module Database
  def self.blog_post_id
    @@blog_post_id ||= BSON::ObjectId.new.to_s
  end

  config = Mocks::real_config
  @@db = Mongo::Connection.new(config.host, config.port).db(config.database)
  
  %w(user blog_post comment).each do |coll|
    @@db[coll].drop
  end

  post1 = {'title' => 'Post1'}
  post2 = {'title' => 'Post2'}
  @@db['blog_post'].insert(post1)
  @@db['blog_post'].insert(post2)

  post1 = @@db['blog_post'].find({'title' => 'Post1'}).first
  post2 = @@db['blog_post'].find({'title' => 'Post2'}).first

  user1 = {'name' => 'John Doe', 'age' => 42, 'gender' => 'Male'}
  user2 = {'name' => 'Jane Smith', 'age' => 37, 'gender' => 'Female', 'likes' => [post1['_id'], post2['_id']]}
  @@db['user'].insert(user1)
  @@db['user'].insert(user2)

  post = {
    '_id' => Database::blog_post_id.to_monger_id, 
    'title' => 'Blog Post', 
    'author_id' => user1.monger_id, 
    'body' => 'Here is a post',
    'date' => Time.utc(2012, 5, 16),
    'time' => {'hour' => 21, 'minute' => 30, 'second' => 0},
    'tags' => [
      {'name' => 'tag1'}, 
      {'name' => 'tag2'}
    ], 
    'related_links' => {
      'urls' => ['http://www.google.com']
    }
  }
  @@db['blog_post'].insert(post)

  comment1 = {'user_id' => user1.monger_id, 'message' => 'A comment', 'blog_post_id' => post.monger_id}
  comment2 = {'user_id' => user2.monger_id, 'message' => 'Another comment', 'blog_post_id' => post.monger_id, 'important' => nil}
  @@db['comment'].insert(comment1)
  @@db['comment'].insert(comment2)

  def find_in_db(type, id)
    @@db[type.to_s].find({'_id' => id}).first
  end
end

module Monger
  module Mongo
    class Database
      @@finds = []

      def self.reset
        @@finds = []
      end

      def self.finds
        @@finds
      end

      def self.finds_of_type(type)
        @@finds.select{|f| f.type == type}
      end

      alias old_find find
      def find(type, criteria={}, options={})
        @@finds << OpenStruct.new(:type => type, :criteria => criteria, :options => options)
        old_find(type, criteria, options)
      end
    end
  end
end