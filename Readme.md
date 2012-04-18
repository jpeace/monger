# Monger

Super simple object mapper for Mongo/Ember/??

## Terminology

* Configuration - An object representing entities and their relationships
* Session - Main entry point for Monger API, provides access to mappers
* Mapper - Responsible for serializing/deserializing entities to a particular format

## Configuration

Monger is configured by specifying the entities in your system as well as the relationships between them. 
This is done in a configuration file using a DSL. For example, if your entities are as follows:

    module Domain
      module Auth
        class User
          attr_accessor :name, :age, :gender, :posts
        end
      end

      class BlogPost
        attr_accessor :author, :title, :body, :comments
      end

      class Comment
        attr_accessor :author, :message
      end
    end

Then your configuration file (e.g. APP_ROOT/config/monger.rb) may look like:

    database 'monger-test'          # Name of your Mongo database
    host 'localhost'                # Database host
    port 27017                      # Database port
    modules Domain, Domain::Auth    # Modules where entities can be found

    # BlogPost configuration
    map :blog_post do |p|
      p.properties :title, :body                  # Primitive properties
      p.has_a :author, :type => :user             # Has-a relationship
      p.has_many :comments, :type => :comment     # Has-many relationship
    end

    # User configuration
    map :user do |u|
      u.properties :name, :age, :gender
      u.has_many :posts, :type => :blog_post, :ref_name => :author
    end

    # Comment configuration
    map :comment do |c|
      c.properties :message
    end


## Usage

Saving/updating entities in a Mongo database
    
    require 'path/to/domain'
    
    config = Monger.bootstrap('/path/to/config')
    session = Monger.create_session(config)
    
    post = Domain::BlogPost.new
    post.author = Domain::Auth::User.new
    # etc...

    session.mongo.save(post)
    id = post.monger_id  # monger_id property is added for each tracked entity

    loaded_post = session.mongo.find_by_id(:blog_post, id)
    loaded_post.title = 'New Title'
    session.mongo.save(loaded_post)