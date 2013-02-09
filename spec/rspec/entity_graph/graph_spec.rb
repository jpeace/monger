#require "../../spec_helper"

describe Monger::EntityGraph::Graph do

  it "can add nodes" do
    subject.add_node Domain::BlogPost.new
    subject.nodes.should have_exactly(1).items
  end

  it "can add edges" do
    post = Domain::BlogPost.new
    author = Domain::Auth::User.new
    subject.add_node post
    subject.add_node author
    subject.add_edge(post, author)
    subject.edges.should have_exactly(1).items
  end

  it "can add nodes automatically when adding edges" do
    subject.add_edge(Domain::BlogPost.new, Domain::Auth::User.new)
    subject.nodes.should have_exactly(2).items
  end

  it "can add a subgraph to itself for a property" do
    author = Domain::Auth::User.new
    subject.add_edge(Domain::BlogPost.new, author)
    subgraph = Monger::EntityGraph::Graph.new
    subgraph.add_edge(Domain::Comment.new, author)
    subgraph.add_edge(Domain::Comment.new, author)
    subject.add_subgraph subgraph
    subject.nodes.should have_exactly(4).items
    subgraph.nodes.each {|node| subject.nodes.should include node}
    subject.edges.should have_exactly(3).items
    subgraph.edges.each {|edge| subject.edges.should include edge}
  end

  it "can sort itself topologically" do
    post1 = Domain::BlogPost.new
    post2 = Domain::BlogPost.new
    author = Domain::Auth::User.new
    coauthor = Domain::Auth::User.new
    comment = Domain::Comment.new
    subject.add_edge(comment, author)
    subject.add_edge(post1, author)
    subject.add_edge(post1, coauthor)
    subject.add_edge(author, post2)
    subject.add_edge(coauthor, post2)
    sorted_list = subject.topo_sort
    post1_index = sorted_list.find_index post1
    post2_index = sorted_list.find_index post2
    author_index = sorted_list.find_index author
    coauthor_index = sorted_list.find_index coauthor
    comment_index = sorted_list.find_index comment
    post1_index.should be < author_index
    post1_index.should be < coauthor_index
    author_index.should be < post2_index
    coauthor_index.should be < post2_index
    comment_index.should be < author_index
  end
end