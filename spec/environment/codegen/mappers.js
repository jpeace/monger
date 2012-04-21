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