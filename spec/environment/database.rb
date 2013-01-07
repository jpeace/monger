require 'mongo'
require 'ostruct'

module Database
  def self.blog_post_id
    "50eb07a1d2648703c3000006".to_monger_id
  end

  def self.user_id
    "50eb07a1d2648703c3000003".to_monger_id
  end

  def self.db
    config = Mocks::real_config
    @@db ||= Mongo::Connection.new(config.host, config.port).db(config.database)
  end
  
  %w(user blog_post comment).each do |coll|
    Database::db[coll].drop
  end

  post1 = {:title => 'Post1'}
  post2 = {:title => 'Post2'}
  Database::db['blog_post'].insert(post1)
  Database::db['blog_post'].insert(post2)

  post1 = Database::db['blog_post'].find({:title => 'Post1'}).first
  post2 = Database::db['blog_post'].find({:title => 'Post2'}).first

  user1 = { :name => 'John Doe', :age => 42, :gender => 'Male'}
  user2 = { :_id => Database::user_id, :name => 'Jane Smith', :age => 37, :gender => 'Female', :likes => [post1['_id'], post2['_id']]}
  user3 = { :name => 'Jane Doe', :age => 14, :gender => 'Female' }
  Database::db['user'].insert(user1)
  Database::db['user'].insert(user2)
  Database::db['user'].insert(user3)

  post = {
    :_id => Database::blog_post_id,
    :title => 'Blog Post',
    :author_id => user1.monger_id,
    :coauthor_id => Database::user_id,
    :body => 'Here is a post',
    :date => Time.utc(2012, 5, 16),
    :time => { :hour => 21, :minute => 30, :second => 0},
    :shares => [
      Database::user_id,
      user3.monger_id
    ],
    :tags => [
      { :name => 'tag1'},
      { :name => 'tag2'}
    ], 
    :related_links => {
      :urls => %w(http://www.google.com)
    }
  }
  Database::db['blog_post'].insert(post)

  comment1 = {:user_id => user1.monger_id, :message => 'A comment', :blog_post_id => post.monger_id}
  comment2 = {:user_id => user2.monger_id, :message => 'Another comment', :blog_post_id => post.monger_id, :important => nil}
  Database::db['comment'].insert(comment1)
  Database::db['comment'].insert(comment2)

  def find_in_db(type, id)
    Database::db[type.to_s].find({:_id => id}).first
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