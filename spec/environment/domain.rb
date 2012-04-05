module Domain
  class BlogPost
    attr_accessor :title, :author, :body, :comments
    def initialize
      yield self if block_given?
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
      attr_accessor :name, :age, :gender, :posts
      def initialize
        yield self if block_given?
      end
    end
  end
end