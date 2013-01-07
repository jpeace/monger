module Domain
  class Tag
    attr_accessor :name, :meta
    def initialize
      yield self if block_given?
    end
  end

  class TagMeta
    attr_accessor :data
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
    attr_accessor :title, :author, :coauthor, :date, :time, :body, :shares, :comments, :tags, :related_links
    def initialize
      @tags = []
      yield self if block_given?
    end
    def add_tag(tag)
      @tags << Tag.new {|t| t.name = tag}
    end
    def remove_tag(tag)
      @tags = @tags.reject {|t| t.name == tag}
    end
  end

  class Comment
    attr_accessor :user, :message, :important
    def initialize
      @important = true
      yield self if block_given?
    end
  end

  module Auth
    class User
      attr_accessor :name, :age, :gender, :posts, :co_posts, :likes, :comments
      def initialize
        yield self if block_given?
      end
    end
  end
end