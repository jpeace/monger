Test.Cache = new (function() {
  this.dict = {};

  this.eachProperty = function(that, obj, callback) {
    for (var prop in obj) {
      if (obj.hasOwnProperty(prop) && prop.indexOf('ember') < 0) {
        callback.call(that, prop);
      }
    }
  };

  this.ensure = function(entity) {
    if (!this.dict[entity]) {
      this.dict[entity] = {};
    }
  };

  this.get = function(entity, id) {
    this.ensure(entity);
    return this.dict[entity][id];
  };

  this.set = function(entity, id, obj) {
    this.ensure(entity);
    if (!this.dict[entity][id]) {
      this.dict[entity][id] = obj;
    } else {
      this.eachProperty(this, obj, function(prop) {
        this.dict[entity][id].set(prop, obj[prop]);
      })
    }
  };
})();

Test.Domain={};

Test.Domain.BlogPost = Ember.Object.extend({
id:'',
author:'',
body:'',
comments:[],
relatedLinks:'',
tags:[],
title:'',

  serialize:function(){
    return JSON.stringify({
id:this.id,
author:this.author,
body:this.body,
comments:this.comments,
relatedLinks:this.relatedLinks,
tags:this.tags,
title:this.title
    });
  }
});

Test.Domain.Comment = Ember.Object.extend({
id:'',
message:'',

  serialize:function(){
    return JSON.stringify({
id:this.id,
message:this.message
    });
  }
});

Test.Domain.Related = Ember.Object.extend({
id:'',
urls:'',

  serialize:function(){
    return JSON.stringify({
id:this.id,
urls:this.urls
    });
  }
});

Test.Domain.Tag = Ember.Object.extend({
id:'',
name:'',

  serialize:function(){
    return JSON.stringify({
id:this.id,
name:this.name
    });
  }
});

Test.Domain.User = Ember.Object.extend({
id:'',
age:'',
gender:'',
name:'',
posts:[],

  serialize:function(){
    return JSON.stringify({
id:this.id,
age:this.age,
gender:this.gender,
name:this.name,
posts:this.posts
    });
  }
});

Test.Mappers={};

Test.Mappers.blogPost = function(obj) {
var author = Test.Mappers.user(obj.author);
var body = obj.body;
var comments = [];
for (var i = 0 ; i < obj.comments.length ; ++i) {
  comments.push(Test.Mappers.comment(obj.comments[i]));
}
var relatedLinks = obj.relatedLinks;
var tags = obj.tags;
var title = obj.title;

  Test.Cache.set('blogPost', obj.id,
    Test.Domain.BlogPost.create({
id:obj.id,
author:author,
body:body,
comments:comments,
relatedLinks:relatedLinks,
tags:tags,
title:title
    })
  );
  return Test.Cache.get('blogPost', obj.id);
};

Test.Mappers.comment = function(obj) {
var message = obj.message;

  Test.Cache.set('comment', obj.id,
    Test.Domain.Comment.create({
id:obj.id,
message:message
    })
  );
  return Test.Cache.get('comment', obj.id);
};

Test.Mappers.related = function(obj) {
var urls = obj.urls;

  Test.Cache.set('related', obj.id,
    Test.Domain.Related.create({
id:obj.id,
urls:urls
    })
  );
  return Test.Cache.get('related', obj.id);
};

Test.Mappers.tag = function(obj) {
var name = obj.name;

  Test.Cache.set('tag', obj.id,
    Test.Domain.Tag.create({
id:obj.id,
name:name
    })
  );
  return Test.Cache.get('tag', obj.id);
};

Test.Mappers.user = function(obj) {
var age = obj.age;
var gender = obj.gender;
var name = obj.name;
var posts = [];
for (var i = 0 ; i < obj.posts.length ; ++i) {
  posts.push(Test.Mappers.blogPost(obj.posts[i]));
}

  Test.Cache.set('user', obj.id,
    Test.Domain.User.create({
id:obj.id,
age:age,
gender:gender,
name:name,
posts:posts
    })
  );
  return Test.Cache.get('user', obj.id);
};