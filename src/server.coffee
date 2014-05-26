# fake api server

express = require 'express'
bodyParser = require 'body-parser'

class Server
  constructor: ->
    @_resources = []
    @_server = express()
    @_server.use bodyParser()

    @_server.on "error", (err) ->
      console.error err

    @_server.get "/api", (req, res) =>
      res.send @_resources.map (resource) ->
        name: resource.name()
        url: "/api/#{resource.pluralName()}"

    @_server.get "/api/:resource", (req, res) =>
      @find req.params.resource, (resource) ->
        return res.send resource.all()

    @_server.get "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        if data = resource.find req.params.id
          return res.send data
        else
          res.statusCode = 404
          res.send "No #{resource.name()} with id #{req.params.id}"

    @_server.post "/api/:resource", (req, res) =>
      @find req.params.resource, (resource) ->
        data = req.body
        resource.add data
        res.send 200

    @_server.put "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        if resource.update req.params.id, req.body
          res.send 200
        else
          res.statusCode = 404
          res.send "No #{resource.name()} with id #{req.params.id}"

    @_server.delete "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        if resource.remove req.params.id
          res.send 200
        else
          res.statusCode = 404
          res.send "No #{resource.name()} with id #{req.params.id}"

  find: (path, cb) ->
    for resource in @_resources
      if resource.pluralName() is path
        return cb resource
    res.send 404

  listen: (port=3000) ->
    @_server.listen port
    console.log "server listening on localhost:#{port}"
    this

  register: (resource) ->
    @_resources = @_resources.concat [resource]
    this

module.exports = Server
