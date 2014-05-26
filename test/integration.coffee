# integration tests for server

chai = require 'chai'
chai.should()

fake = require '../lib'
http = require 'http'

_port = 3000
nextPort = -> _port = _port + 1

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
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api", (res) ->
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

  it "handles GET /api/books", ->
    books = new fake.Resource "book"
      .add name: "foo"
      .add name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/books", (res) ->
      buffer = ''
      res.on 'data', (d) -> buffer += d.toString()
      res.on 'end', ->
        all = JSON.parse buffer

        names = all.map (d) -> d.name
        names.should.contain "foo"
        names.should.contain "bar"
        names.should.contain "baz"

  it "handles GET /api/books/:id", ->
    books = new fake.Resource "book"
      .add name: "foo"
      .add bar = name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/books/#{bar.id}", (res) ->
      buffer = ''
      res.on 'data', (d) -> buffer += d.toString()
      res.on 'end', ->
        record = JSON.parse buffer

        record.id.should.equal bar.id
        record.name.should.equal "bar"

  it "handles 404 on GET /api/books/:id", ->
    books = new fake.Resource "book"
      .add name: "foo"
      .add name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/books/8383", (res) ->
      res.statusCode.should.equal 404
