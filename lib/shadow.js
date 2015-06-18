var shadow = function(initial) {
  var objs = [initial || Object.create(null)];
  var set = function(k, v) {
    objs[0][k] = v;
  };
  var rem = function(k) {
    set(k, undefined);
  };
  var get = function(k) {
    var i, v;
    for (i=0; i < objs.length; i++) {
      if (Object.prototype.hasOwnProperty.call(objs[i], k)) {
        v = objs[i][k];
        if (v !== undefined) {
          return v;
        }
      }
    }
  };
  var add = function(obj) {
    return objs.push(obj);
  };
  var has = function(k) {
    return get(k) !== undefined;
  };
  return {
    get: get,
    set: set,
    rem: rem,
    add: add,
    has: has
  };
};

module.exports = shadow;
