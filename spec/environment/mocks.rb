require 'monger/config'

module Mocks
  class ConfigMock < Monger::Configuration
    def initialize
      @modules = [Domain::Auth, Domain]
    end
  end

  def config
    ConfigMock.new
  end

  def self.real_config
    Monger::Configuration.from_file("#{environment_root}/config/monger.rb")
  end


  class Api

    attr_reader :config

    def initialize
      @config = ::Mocks::real_config
      @blog_posts = [
          Domain::BlogPost.new {|bp| bp.monger_id = '50eb46cad264870783000001'.to_monger_id; bp.title = 'Post1'},
          Domain::BlogPost.new {|bp| bp.monger_id = '50eb46cad264870783000002'.to_monger_id; bp.title = 'Post2'}
      ]
      @users = [
          Domain::Auth::User.new {|u| u.monger_id = '50eb46cad264870783000003'.to_monger_id; u.name = 'John Doe'; u.age = 42; u.gender = 'Male' },
          Domain::Auth::User.new {|u| u.monger_id = '50eb07a1d2648703c3000003'.to_monger_id; u.name = 'Jane Smith'; u.age = 37; u.gender = 'Female'; u.likes = %w(50eb46cad264870783000001 50eb46cad264870783000002) },
          Domain::Auth::User.new {|u| u.monger_id = '50eb46cad264870783000004'.to_monger_id; u.name = 'Jane Doe'; u.age = 14; u.gender = 'Female' }
      ]
      @blog_posts << Domain::BlogPost.new do |bp|
        bp.monger_id = '50eb07a1d2648703c3000006'.to_monger_id
        bp.title = 'Blog Post'
        bp.author = @users[0]
        bp.coauthor = @users[1]
        bp.body = 'Here is a post'
        bp.date = Time.utc(2012, 5, 16)
        bp.time = TimeOfDay.new(21, 30, 0)
        bp.shares = [ @users[1], @users[2] ]
        bp.tags = [ Domain::Tag.new {|t| t.name = 'tag1'}, Domain::Tag.new {|t| t.name = 'tag2'} ]
        bp.related_links = Domain::Related.new {|r| r.urls = %w(http://www.google.com) }
      end
      @comments = [
          Domain::Comment.new {|c| c.monger_id = '50eb46cad264870783000005'.to_monger_id; c.user = @users[0]; c.message = 'A comment'},
          Domain::Comment.new {|c| c.monger_id = '50eb46cad264870783000006'.to_monger_id; c.user = @users[1]; c.message = 'Another comment'; c.important = nil}
      ]
    end

    def find(type, criteria, options={})
      case type
        when :user
          [ @users[1], @users[2] ]
        when :comment
          [ @comments[0] ]
        when :blog_post
          [ @blog_posts[0] ]
      end
    end

    def find_by_id(type, id, options={})
      case type
        when :user
          @users.select{|user| user.monger_id == id}.first
        when :blog_post
          @blog_posts.select{|bp| bp.monger_id == id}.first
      end
    end
  end
end