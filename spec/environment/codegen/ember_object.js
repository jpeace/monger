Test.Domain.BlogPost = Ember.Object.extend({
id:'',
author:'',
body:'',
comments:[],
relatedLinks:'',
tags:[],
title:'',

  isNew:function() { !this.id; }.property('id'),
  serialize:function(){
var author = null;
if (this.author) {
  author = this.author.serialize();
}
var comments = [];
for (var i = 0 ; i < this.comments.length ; ++i) {
  comments.push(this.comments[i].serialize());
}
var relatedLinks = null;
if (this.relatedLinks) {
  relatedLinks = this.relatedLinks.serialize();
}
var tags = [];
for (var i = 0 ; i < this.tags.length ; ++i) {
  tags.push(this.tags[i].serialize());
}
    return {
id:this.id,
author:author,
body:this.body,
comments:comments,
relatedLinks:relatedLinks,
tags:tags,
title:this.title
    };
  }
});