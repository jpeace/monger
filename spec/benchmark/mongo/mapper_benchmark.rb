require 'monger'
require_relative '../profiler/profiler'
require_relative '../../spec_helper'
require_relative '../../environment/objects/benchmark'
include ::BenchmarkObjects

profiler = ::Benchmark::Profiler.new

profiler.before_each do
	config = ::Monger.bootstrap("#{::File.dirname(__FILE__)}/../../environment/config/monger.rb")
	session = ::Monger.create_session(config)
	@mapper = ::Monger::Mongo::Mapper.new(session.mongo)
  @post = build_post
  @post_doc = build_post_doc
	@post_map = config.maps[:blog_post]
end

profiler.profile_process_time('mongo/mapper/#entity_to_doc', iterate: 1000) do
	@mapper.entity_to_doc(@post_map, @post)
end

profiler.profile_process_time('mongo/mapper/#doc_to_entity', iterate: 1000) do
  @mapper.doc_to_entity(@post_map, @post_doc)
end