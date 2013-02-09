require 'monger'
require_relative '../profiler/profiler'
require_relative '../../spec_helper'

profiler = ::Monger::Benchmark::Profiler.new

profiler.before_each do
	config = ::Monger.bootstrap("#{::File.dirname(__FILE__)}/../../environment/config/monger.rb")
	session = ::Monger.create_session(config)
	@mapper = ::Monger::Mongo::Mapper.new(session.mongo)
	@blog_post_map = config.maps[:blog_post]
end

post = Domain::BlogPost.new do |p|
  p.title = 'Title'
  p.body = 'Body'
  p.date = Time.utc(2012, 5, 16)
  p.time = TimeOfDay.new(9, 30, 0, :pm)
  p.author = Domain::Auth::User.new do |u|
    u.name = 'Author'
    u.age = 30
    u.gender = 'M'
  end
  p.comments = [
    Domain::Comment.new do |c|
      c.user = Domain::Auth::User.new do |u|
        u.name = 'Commenter'
        u.age = 22
        u.gender = 'F'
      end
      c.message = 'Comment!'
    end
  ]
  p.tags = [Domain::Tag.new {|t| t.name = 'Tag1'}, Domain::Tag.new {|t| t.name = 'Tag2'}]
  p.related_links = Domain::Related.new do |r|
    r.urls = ['http://www.google.com']
  end
end

profiler.profile_process_time 'mongo/mapper/#entity_to_doc' do
	1000.times { @mapper.entity_to_doc(@blog_post_map, post) }
end

# profiler.profile 'mongo/mapper/#doc_to_entity' do

# end