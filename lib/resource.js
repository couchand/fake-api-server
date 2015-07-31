(function() {
  var Resource;

  Resource = (function() {
    function Resource(_name1) {
      this._name = _name1;
      if (!(this instanceof Resource)) {
        return new Resource(_name);
      }
      this._records = [];
      this._idAttribute = "id";
      this._idFactory = (function(_this) {
        return function() {
          var d;
          return 1 + Math.max(0, Math.max.apply(Math, (function() {
            var i, len, ref, results;
            ref = this._records;
            results = [];
            for (i = 0, len = ref.length; i < len; i++) {
              d = ref[i];
              results.push(d[this._idAttribute]);
            }
            return results;
          }).call(_this)));
        };
      })(this);
    }

    Resource.prototype.idAttribute = function() {
      if (arguments.length === 0) {
        return this._idAttribute;
      } else {
        this._idAttribute = arguments[0];
        return this;
      }
    };

    Resource.prototype.idFactory = function() {
      if (arguments.length === 0) {
        return this._idFactory;
      } else {
        this._idFactory = arguments[0];
        return this;
      }
    };

    Resource.prototype.name = function() {
      if (arguments.length === 0) {
        return this._name;
      } else {
        this._name = arguments[0];
        return this;
      }
    };

    Resource.prototype.pluralName = function() {
      if (arguments.length === 0) {
        if (this._pluralName) {
          return this._pluralName;
        } else {
          return this._name + "s";
        }
      } else {
        this._pluralName = arguments[0];
        return this;
      }
    };

    Resource.prototype.all = function() {
      return this._records;
    };

    Resource.prototype.add = function(record) {
      record[this._idAttribute] = this._idFactory();
      this._records = this._records.concat([record]);
      return this;
    };

    Resource.prototype.find = function(id) {
      var record;
      record = this._records.filter((function(_this) {
        return function(d) {
          return ("" + d[_this._idAttribute]) === ("" + id);
        };
      })(this));
      if (record.length) {
        return record[0];
      } else {
        return false;
      }
    };

    Resource.prototype.update = function(id, updates) {
      var name, record, value;
      record = this.find(id);
      if (!record) {
        return false;
      }
      for (name in updates) {
        value = updates[name];
        if (name !== this._idAttribute) {
          record[name] = value;
        }
      }
      return record;
    };

    Resource.prototype.remove = function(id) {
      var record;
      record = this.find(id);
      if (!record) {
        return false;
      }
      this._records = this._records.filter((function(_this) {
        return function(d) {
          return ("" + d[_this._idAttribute]) !== ("" + id);
        };
      })(this));
      return true;
    };

    return Resource;

  })();

  module.exports = Resource;

}).call(this);
