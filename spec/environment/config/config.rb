database 'my_db'
host 'localhost'
port 8888
modules Domain, Domain::Auth

map :blog_post do |p|
  p.all_properties
  p.has_a :author, :type => :user
end

map :user do |u|
  u.all_properties
  u.exclude :full_name
  u.has_many :posts, :type => :blog_post
end