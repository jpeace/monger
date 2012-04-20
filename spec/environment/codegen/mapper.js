Test.Mappers.blogPost = function(obj) {
  var author = Test.Mappers.user(obj.author);
  var comments = [];
  for (var i = 0 ; i < obj.comments.length ; ++i) {
    comments.push(Test.Mappers.comment(obj.comments[i]));
  }
  Test.Cache.set('blogPost', obj.id,
    Test.Domain.BlogPost.create({
      id:obj.id,
      author:author,
      body:obj.body,
      comments:comments,
      relatedLinks:obj.relatedLinks,
      tags:obj.tags
      title:obj.title
    })
  );
  return Test.Cache.get('blogPost', obj.id);
};