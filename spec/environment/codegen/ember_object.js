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