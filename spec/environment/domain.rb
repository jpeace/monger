module Domain
  class BlogPost
    attr_accessor :title, :author, :body
  end
end

module Domain
  module Auth
    class User
      attr_accessor :name, :age, :gender
    end
  end
end