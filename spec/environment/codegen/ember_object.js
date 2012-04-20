Test.Domain.Related = Ember.Object.extend({
  id:'',
  urls:[],

  serialize:function() {
    return JSON.stringify({
      id:this.id,
      urls:this.urls
    });
  }
});