Test.Mappers.blogPost = function(obj) {
  if (!obj) {
    return null;
  }
var author = Test.Mappers.user(obj.author);
var body = obj.body;
var coauthor = Test.Mappers.user(obj.coauthor);
var comments = [];
if (obj.comments) {
  for (var i = 0 ; i < obj.comments.length ; ++i) {
    comments.push(Test.Mappers.comment(obj.comments[i]));
  }
}
var date = obj.date;
var relatedLinks = Test.Mappers.related(obj.relatedLinks);
var shares = [];
if (obj.shares) {
  for (var i = 0 ; i < obj.shares.length ; ++i) {
    shares.push(Test.Mappers.user(obj.shares[i]));
  }
}
var tags = [];
if (obj.tags) {
  for (var i = 0 ; i < obj.tags.length ; ++i) {
    tags.push(Test.Mappers.tag(obj.tags[i]));
  }
}
var time = obj.time;
var title = obj.title;

var entity = Test.Domain.BlogPost.create({
id:obj.id,
author:author,
body:body,
coauthor:coauthor,
comments:comments,
date:date,
relatedLinks:relatedLinks,
shares:shares,
tags:tags,
time:time,
title:title
});

  if (obj.id) {
    Test.Cache.set('blogPost', obj.id, entity);
  }
  return entity;
};