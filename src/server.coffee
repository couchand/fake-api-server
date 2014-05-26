# fake api server

express = require 'express'
bodyParser = require 'body-parser'

class Server
  constructor: ->
    @_resources = []
    @_server = express()
    @_server.use bodyParser()

    @_server.get "/api", (req, res) =>
      res.send @_resources.map (resource) ->
        name: resource.name()
        url: "/api/#{resource.pluralName()}"

    @_server.get "/api/:resource", (req, res) =>
      for resource in @_resources
        if resource.pluralName() is req.params.resource
          return res.send resource.all()
      res.send 404

    @_server.get "/api/:resource/:id", (req, res) =>
      for resource in @_resources
        if resource.pluralName() is req.params.resource
          if data = resource.find req.params.id
            return res.send data
          else
            res.statusCode = 404
            res.send "No #{resource.name()} with id #{req.params.id}"

  listen: (port=3000) ->
    @_server.listen port
    console.log "server listening on localhost:#{port}"
    this

  register: (resource) ->
    @_resources = @_resources.concat [resource]

    url = (path='') ->
      "/api/#{resource.pluralName()}#{path}"

    @_server.post url(), (req, res) ->
      data = req.body
      resource.add data
      res.send 200

    @_server.put url("/:id"), (req, res) ->
      if resource.update id, req.body
        res.send 200
      else
        res.statusCode = 404
        res.send "No #{resource.name()} with id #{req.params.id}"

    @_server.delete url("/:id"), (req, res) ->
      if resource.remove id
        res.send 200
      else
        res.statusCode = 404
        res.send "No #{resource.name()} with id #{req.params.id}"

    this

module.exports = Server
