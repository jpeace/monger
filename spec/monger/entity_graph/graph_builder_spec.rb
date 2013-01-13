#require "../../spec_helper"

describe Monger::EntityGraph::GraphBuilder do
  subject {described_class.new(Mocks::real_config)}

  it "can build simple graphs" do
    post = Domain::BlogPost.new
    graph = subject.create_graph post
    graph.nodes.should have_exactly(1).items
    graph.nodes.should include post
  end

  it "can build graphs with inline references" do
    post = Domain::BlogPost.new
    post.related_links = Domain::Related.new
    post.related_links.urls = %w(http://www.google.com http://www.musicone.com)
    graph = subject.create_graph post
    graph.nodes.should have_exactly(1).items
    graph.nodes.should include post
  end

  it "can build graphs with id references" do
    post = Domain::BlogPost.new
    post.author = Domain::Auth::User.new
    graph = subject.create_graph post
    graph.nodes.should have_exactly(2).items
    graph.nodes.should include post, post.author
    graph.edges.should include({ :from => post, :to => post.author })
  end

  it "can build graphs with inline collections" do
    post = Domain::BlogPost.new
    post.tags = [ Domain::Tag.new, Domain::Tag.new ]
    graph = subject.create_graph post
    graph.nodes.should have_exactly(1).items
    graph.nodes.should include post
  end

  it "can build graphs with inverse collections" do
    post = Domain::BlogPost.new
    post.shares = [ Domain::Auth::User.new, Domain::Auth::User.new, Domain::Auth::User.new ]
    graph = subject.create_graph post
    graph.nodes.should have_exactly(4).items
    graph.nodes.should include post, post.shares[0], post.shares[1], post.shares[2]
    graph.edges.should have_exactly(3).items
    graph.edges.should include({ :from => post, :to => post.shares[0] }, { :from => post, :to => post.shares[1] }, { :from => post, :to => post.shares[2] })
  end

  it "can build graphs with mapped collections" do
    post = Domain::BlogPost.new
    post.comments = [ Domain::Comment.new, Domain::Comment.new ]
    graph = subject.create_graph post
    graph.nodes.should have_exactly(3).items
    graph.nodes.should include post, post.comments[0], post.comments[1]
    graph.edges.should have_exactly(2).items
    graph.edges.should include({ :from => post.comments[0], :to => post }, { :from => post.comments[1], :to => post })
  end
end