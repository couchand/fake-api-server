# fake api server

express = require 'express'
bodyParser = require 'body-parser'

class Server
  constructor: ->
    return new Server() unless @ instanceof Server

    @_resources = []
    @_server = express()
    @_server.use bodyParser()

    @_server.on "error", (err) ->
      console.error err

  _setupRoutes: ->
    @_server.get "/api", (req, res) =>
      res.send @_resources.map (resource) ->
        name: resource.name()
        url: "/api/#{resource.pluralName()}"

    @_server.get "/api/:resource", (req, res) =>
      @find req.params.resource, (resource) ->
        unless resource
          return res.sendStatus 404

        res.send resource.all()

    @_server.get "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        unless resource
          return res.sendStatus 404

        unless data = resource.find req.params.id
          res.statusCode = 404
          return res.send "No #{resource.name()} with id #{req.params.id}"

        res.send data

    @_server.post "/api/:resource", (req, res) =>
      @find req.params.resource, (resource) ->
        unless resource
          return res.sendStatus 404

        data = req.body
        resource.add data
        res.sendStatus 200

    @_server.put "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        unless resource
          return res.sendStatus 404

        if resource.update req.params.id, req.body
          res.sendStatus 200
        else
          res.statusCode = 404
          res.send "No #{resource.name()} with id #{req.params.id}"

    @_server.delete "/api/:resource/:id", (req, res) =>
      @find req.params.resource, (resource) ->
        unless resource
          return res.sendStatus 404

        if resource.remove req.params.id
          res.sendStatus 200
        else
          res.statusCode = 404
          res.send "No #{resource.name()} with id #{req.params.id}"

  find: (path, cb) ->
    for resource in @_resources
      if resource.pluralName() is path
        return cb resource
    cb null

  use: (middleware) ->
   @_server.use middleware
   this

  static: (path) ->
    @use express.static path

  listen: (port=3000) ->
    throw new Error "Cannot call listen more than once!" if @_initialized
    @_setupRoutes()
    @_initialized = yes

    @_server.listen port
    this

  register: (resource) ->
    @_resources = @_resources.concat [resource]
    this

module.exports = Server
