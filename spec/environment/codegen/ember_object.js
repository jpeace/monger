Test.Domain.BlogPost = Ember.Object.extend({
id:'',
author:'',
body:'',
comments:[],
related_links:'',
tags:[],
title:'',

  serialize:function(){
    return JSON.stringify({
id:this.id,
author:this.author,
body:this.body,
comments:this.comments,
related_links:this.related_links,
tags:this.tags,
title:this.title
    });
  }
});