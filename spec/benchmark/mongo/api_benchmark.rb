require 'monger'
require_relative '../profiler/profiler'
require_relative '../../spec_helper'
require_relative '../../environment/objects/benchmark'
include ::BenchmarkObjects

profiler = ::Benchmark::Profiler.new

profiler.before_each do
	config = ::Monger.bootstrap("#{::File.dirname(__FILE__)}/../../environment/config/monger.rb")
	session = ::Monger.create_session(config)
  @api = session.mongo
  @post = build_post
  @post_doc = build_post_doc
	@post_map = config.maps[:blog_post]
end

profiler.profile_process_time('mongo/api/#find_by_id', iterate: 1000) do
	@api.find_by_id(:blog_post, "50eb07a1d2648703c3000006")
end

profiler.profile_process_time('mongo/api/#find', iterate: 1000) do
	@api.find(:blog_post, { title: 'Blog Post' })
end

profiler.profile_process_time('mongo/api/#find_all', iterate: 1000) do
	@api.find_all(:blog_post)
end

profiler.profile_process_time('mongo/api/#find_one', iterate: 1000) do
	@api.find_one(:blog_post, { title: 'BlogPost' })
end