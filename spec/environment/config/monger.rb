database 'monger-test'
host 'localhost'
port 27017

js_namespace 'Test'

modules Domain, Domain::Auth

map :tag do |t|
  t.properties :name
  t.has_a :meta, :type => :tag_meta, :inline => true
end

map :tag_meta do |m|
  m.properties :data
end

map :related do |r|
  r.properties :urls
end

map :blog_post do |p|
  p.properties :title, :body
  p.date :date
  p.time :time
  p.has_a :author, :type => :user, :delete => true, :load_type => :eager
  p.has_a :coauthor, :type => :user
  p.has_many :shares, :type => :user, :inverse => true, :load_type => :eager
  p.has_many :comments, :type => :comment, :delete => true
  p.has_many :tags, :type => :tag, :inline => true
  p.has_a :related_links, :type => :related, :inline => true
end

map :user do |u|
  u.properties :name, :age, :gender
  u.has_many :posts, :type => :blog_post, :ref_name => :author
  u.has_many :co_posts, :type => :blog_post, :ref_name => :coauthor
  u.has_many :comments, :type => :comment, :load_type => :eager
  u.has_many :likes, :type => :blog_post, :inverse => true
end

map :comment do |c|
  c.properties :message, :important
end