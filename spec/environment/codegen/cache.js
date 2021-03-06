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
    var entityList = new Array();
    for (var key in this.dict[entity]) {
      entityList.push(this.dict[entity][key]);
    }
    return entityList;
  };

  this.getBy = function(entity, prop, val) {
    this.ensure(entity);
    for (var key in this.dict[entity]) {
      if (this.dict[entity][key][prop] == val) {
        return this.dict[entity][key];
      }
    }
    return null;
  };

  this.set = function(entity, id, obj) {
    this.ensure(entity);
    if (!this.dict[entity][id]) {
      this.dict[entity][id] = obj;
    } else {
      this.eachProperty(this, obj, function(prop) {
        if (this.dict[entity][id].get(prop) == '' || this.dict[entity][id].get(prop) == []) {
          this.dict[entity][id].set(prop, obj[prop]);
        }
      })
    }
  };
})();