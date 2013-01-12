Test.Domain.BlogPost = Ember.Object.extend({
id:'',
author:'',
body:'',
coauthor:'',
comments:[],
date:'',
relatedLinks:'',
shares:[],
tags:[],
time:'',
title:'',

  isNew:function() { return !this.id; }.property('id'),
  serialize:function(){
var author = null;
if (this.author) {
  author = this.author.serialize();
}
var coauthor = null;
if (this.coauthor) {
  coauthor = this.coauthor.serialize();
}
var comments = [];
for (var i = 0 ; i < this.comments.length ; ++i) {
  comments.push(this.comments[i].serialize());
}
var relatedLinks = null;
if (this.relatedLinks) {
  relatedLinks = this.relatedLinks.serialize();
}
var shares = [];
for (var i = 0 ; i < this.shares.length ; ++i) {
  shares.push(this.shares[i].serialize());
}
var tags = [];
for (var i = 0 ; i < this.tags.length ; ++i) {
  tags.push(this.tags[i].serialize());
}
    return {
id:this.id,
author:author,
body:this.body,
coauthor:coauthor,
comments:comments,
date:this.date,
relatedLinks:relatedLinks,
shares:shares,
tags:tags,
time:this.time,
title:this.title
    };
  }
});