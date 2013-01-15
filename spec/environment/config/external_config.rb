modules Domain

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