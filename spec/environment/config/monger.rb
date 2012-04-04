database 'monger-test'
host 'localhost'
port 27017
modules Domain, Domain::Auth

map :blog_post do |p|
  p.properties :title, :body
  p.has_a :author, :type => :user
  p.has_many :comments, :type => :comment
end

map :user do |u|
  u.properties :name, :age, :gender
end

map :comment do |c|
  c.properties :message
end