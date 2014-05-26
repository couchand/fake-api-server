# integration tests for server

chai = require 'chai'
chai.should()

fake = require '../lib'
http = require 'http'

describe "server", ->
  it "handles index requests", ->
    books = new fake.Resource "book"
    music = new fake.Resource "music"
      .pluralName "music"
    tools = new fake.Resource "tool"

    server = new fake.Server()
      .register books
      .register music
      .register tools
      .listen 3000

    http.get "http://localhost:3000/api", (res) ->
      buffer = ''
      res.on 'data', (d) -> buffer += d.toString()
      res.on 'end', ->
        all = JSON.parse buffer
        names = all.map (d) -> d.name
        names.should.contain "book"
        names.should.contain "music"
        names.should.contain "tool"
        paths = all.map (d) -> d.url
        paths.should.contain "/api/books"
        paths.should.contain "/api/music"
        paths.should.contain "/api/tools"
