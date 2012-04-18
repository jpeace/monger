require 'mongo'

module Database
  def self.blog_post_id
    @@blog_post_id ||= BSON::ObjectId.new.to_s
  end

  config = Mocks::real_config
  @@db = Mongo::Connection.new(config.host, config.port).db(config.database)
  
  %w(user blog_post comment).each do |coll|
    @@db[coll].drop
  end

  user1 = {'name' => 'John Doe', 'age' => 42, 'gender' => 'Male'}
  user2 = {'name' => 'Jane Smith', 'age' => 37, 'gender' => 'Female'}
  @@db['user'].insert(user1)
  @@db['user'].insert(user2)

  post = {'_id' => Database::blog_post_id.to_monger_id, 'title' => 'Blog Post', 'author_id' => user1.monger_id, 'body' => 'Here is a post'}
  @@db['blog_post'].insert(post)

  comment1 = {'user_id' => user1.monger_id, 'message' => 'A comment', 'blog_post_id' => post.monger_id}
  comment2 = {'user_id' => user2.monger_id, 'message' => 'Another comment', 'blog_post_id' => post.monger_id}
  @@db['comment'].insert(comment1)
  @@db['comment'].insert(comment2)

  def find_in_db(type, id)
    @@db[type.to_s].find({'_id' => id}).first
  end
end