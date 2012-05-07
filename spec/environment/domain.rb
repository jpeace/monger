module Domain
  class Tag
    attr_accessor :name
    def initialize
      yield self if block_given?
    end
  end

  class Related
    attr_accessor :urls
    def initialize
      @urls = []
      yield self if block_given?
    end
  end

  class BlogPost
    attr_accessor :title, :author, :body, :comments, :tags, :related_links
    def initialize
      @tags = []
      yield self if block_given?
    end
    def add_tag(tag)
      @tags << Tag.new {|t| t.name=tag}
    end
  end

  class Comment
    attr_accessor :user, :message
    def initialize
      yield self if block_given?
    end
  end

  module Auth
    class User
      attr_accessor :name, :age, :gender, :posts, :likes
      def initialize
        yield self if block_given?
      end
    end
  end
end