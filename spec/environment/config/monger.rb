database 'monger-test'
host 'localhost'
port 27017

js_namespace 'Test'

modules Domain, Domain::Auth

map :tag do |t|
  t.properties :name
end

map :related do |r|
  r.properties :urls
end

map :blog_post do |p|
  p.properties :title, :body
  p.has_a :author, :type => :user, :delete => true
  p.has_many :comments, :type => :comment, :update => true, :delete => true
  p.has_many :tags, :type => :tag, :inline => true
  p.has_a :related_links, :type => :related, :inline => true
end

map :user do |u|
  u.properties :name, :age, :gender
  u.has_many :posts, :type => :blog_post, :ref_name => :author
  u.has_many :likes, :type => :blog_post, :inverse => true
end

map :comment do |c|
  c.properties :message
end