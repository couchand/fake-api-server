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

  listen: (port=3000) ->
    @_server.listen port
    console.log "server listening on localhost:#{port}"
    this

  register: (resource) ->
    @_resources = @_resources.concat [resource]

    url = (path='') ->
      "/api/#{resource.pluralName()}#{path}"

    @_server.get url(), (req, res) ->
      res.send resource.all()

    @_server.get url("/:id"), (req, res) ->
      data = resource.find req.params.id
      if data
        res.send data
      else
        res.statusCode = 404
        res.send "No #{resource.name()} with id #{req.params.id}"

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
