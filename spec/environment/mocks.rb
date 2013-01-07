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
    end

    def find(type, criteria, options={})
      case type
        when :user
          [ Domain::Auth::User.new {|u| u.name = "Jane Smith"} ]
        when :comment
          [ Domain::Comment.new {|c| c.message = "A comment"} ]
      end
    end

    def find_by_id(type, id, options={})
      case type
        when :user
          Domain::Auth::User.new {|u| u.name = "John Doe"}
        when :blog_post
          Domain::BlogPost.new {|bp| bp.title = "Post1"}
      end
    end
  end
end