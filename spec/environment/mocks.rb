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
          Domain::BlogPost.new {|bp| bp.monger_id = "50eb07a1d2648703c3000006".to_monger_id; bp.title = "Blog Post"},
          Domain::BlogPost.new {|bp| bp.monger_id = "50eb46cad264870783000001".to_monger_id; bp.title = "Post1"}
      ]
      @users = [
          Domain::Auth::User.new {|u| u.monger_id = "50eb46cad264870783000003".to_monger_id; u.name = "John Doe"},
          Domain::Auth::User.new {|u| u.monger_id = "50eb07a1d2648703c3000003".to_monger_id; u.name = "Jane Smith"},
          Domain::Auth::User.new {|u| u.monger_id = "50eb46cad264870783000004".to_monger_id; u.name = "Jane Doe"}
      ]
      @comments = [
          Domain::Comment.new {|c| c.monger_id = "50eb46cad264870783000005".to_monger_id; c.message = "A comment"}
      ]
    end

    def find(type, criteria, options={})
      case type
        when :user
          [ @users[1] ]
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