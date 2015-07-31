(function() {
  var Server, bodyParser, express;

  express = require('express');

  bodyParser = require('body-parser');

  Server = (function() {
    function Server() {
      if (!(this instanceof Server)) {
        return new Server();
      }
      this._resources = [];
      this._server = express();
      this._server.use(bodyParser.json());
      this._server.on("error", function(err) {
        return console.error(err);
      });
    }

    Server.prototype._setupRoutes = function() {
      this._server.get("/api", (function(_this) {
        return function(req, res) {
          return res.send(_this._resources.map(function(resource) {
            return {
              name: resource.name(),
              url: "/api/" + (resource.pluralName())
            };
          }));
        };
      })(this));
      this._server.get("/api/:resource", (function(_this) {
        return function(req, res) {
          return _this.find(req.params.resource, function(resource) {
            if (!resource) {
              return res.sendStatus(404);
            }
            return res.send(resource.all());
          });
        };
      })(this));
      this._server.get("/api/:resource/:id", (function(_this) {
        return function(req, res) {
          return _this.find(req.params.resource, function(resource) {
            var data;
            if (!resource) {
              return res.sendStatus(404);
            }
            if (!(data = resource.find(req.params.id))) {
              res.statusCode = 404;
              return res.send("No " + (resource.name()) + " with id " + req.params.id);
            }
            return res.send(data);
          });
        };
      })(this));
      this._server.post("/api/:resource", (function(_this) {
        return function(req, res) {
          return _this.find(req.params.resource, function(resource) {
            var data;
            if (!resource) {
              return res.sendStatus(404);
            }
            data = req.body;
            resource.add(data);
            return res.sendStatus(200);
          });
        };
      })(this));
      this._server.put("/api/:resource/:id", (function(_this) {
        return function(req, res) {
          return _this.find(req.params.resource, function(resource) {
            if (!resource) {
              return res.sendStatus(404);
            }
            if (resource.update(req.params.id, req.body)) {
              return res.sendStatus(200);
            } else {
              res.statusCode = 404;
              return res.send("No " + (resource.name()) + " with id " + req.params.id);
            }
          });
        };
      })(this));
      return this._server["delete"]("/api/:resource/:id", (function(_this) {
        return function(req, res) {
          return _this.find(req.params.resource, function(resource) {
            if (!resource) {
              return res.sendStatus(404);
            }
            if (resource.remove(req.params.id)) {
              return res.sendStatus(200);
            } else {
              res.statusCode = 404;
              return res.send("No " + (resource.name()) + " with id " + req.params.id);
            }
          });
        };
      })(this));
    };

    Server.prototype.find = function(path, cb) {
      var i, len, ref, resource;
      ref = this._resources;
      for (i = 0, len = ref.length; i < len; i++) {
        resource = ref[i];
        if (resource.pluralName() === path) {
          return cb(resource);
        }
      }
      return cb(null);
    };

    Server.prototype.use = function(middleware) {
      this._server.use(middleware);
      return this;
    };

    Server.prototype["static"] = function(path) {
      return this.use(express["static"](path));
    };

    Server.prototype.listen = function(port) {
      if (port == null) {
        port = 3000;
      }
      if (this._initialized) {
        throw new Error("Cannot call listen more than once!");
      }
      this._setupRoutes();
      this._initialized = true;
      this._server.listen(port);
      return this;
    };

    Server.prototype.register = function(resource) {
      this._resources = this._resources.concat([resource]);
      return this;
    };

    return Server;

  })();

  module.exports = Server;

}).call(this);
