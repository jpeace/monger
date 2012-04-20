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