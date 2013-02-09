module BenchmarkObjects

	def build_post
		Domain::BlogPost.new do |p|
		  p.title = 'Title'
		  p.body = 'Body'
		  p.date = Time.utc(2012, 5, 16)
		  p.time = TimeOfDay.new(9, 30, 0, :pm)
		  p.author = Domain::Auth::User.new do |u|
		    u.name = 'Author'
		    u.age = 30
		    u.gender = 'M'
		  end
		  p.comments = [
		    Domain::Comment.new do |c|
		      c.user = Domain::Auth::User.new do |u|
		        u.name = 'Commenter'
		        u.age = 22
		        u.gender = 'F'
		      end
		      c.message = 'Comment!'
		    end
		  ]
		  p.tags = [Domain::Tag.new {|t| t.name = 'Tag1'}, Domain::Tag.new {|t| t.name = 'Tag2'}]
		  p.related_links = Domain::Related.new do |r|
		    r.urls = %w(http://www.google.com)
		  end
		end
	end

	def build_post_doc
		{
		  id: Database::blog_post_id.to_s,
		  title: "Title",
		  body: "Body",
		  date: "5/16/2012",
		  time: "9:30 PM",
		  author: "50eb46cad264870783000003",
		  coauthor: "50eb46cad264870783000004",
		  shares: [],
		  tags: [
		    { name: "Tag1" },
		    { name: "Tag2" }
		  ],
		  relatedLinks: {
		    urls: %w(http://www.google.com)
		  }
		}
	end

	def build_user

	end

	def build_user_doc

	end

end