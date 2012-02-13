map :blog_post do |p|
  p.all_properties
end

map :user do |u|
  u.all_properties
  u.exclude :full_name
  u.has_many :posts
end