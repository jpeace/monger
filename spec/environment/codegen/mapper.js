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