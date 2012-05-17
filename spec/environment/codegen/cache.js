Test.Cache = new (function() {
  this.dict = {};

  this.eachProperty = function(that, obj, callback) {
    for (var prop in obj) {
      if (obj.hasOwnProperty(prop) && prop.indexOf('ember') < 0) {
        callback.call(that, prop);
      }
    }
  };

  this.ensure = function(entity) {
    if (!this.dict[entity]) {
      this.dict[entity] = {};
    }
  };

  this.get = function(entity, id) {
    this.ensure(entity);
    return this.dict[entity][id];
  };

  this.getAll = function(entity) {
    return this.dict[entity];
  }

  this.set = function(entity, id, obj) {
    this.ensure(entity);
    if (!this.dict[entity][id]) {
      this.dict[entity][id] = obj;
    } else {
      this.eachProperty(this, obj, function(prop) {
        this.dict[entity][id].set(prop, obj[prop]);
      })
    }
  };
})();