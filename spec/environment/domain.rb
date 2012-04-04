module Domain
  class BlogPost
    attr_accessor :title, :author, :body, :comments
  end

  class Comment
    attr_accessor :user, :message
  end

  module Auth
    class User
      attr_accessor :name, :age, :gender
    end
  end
end