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
      res.statusCode.should.equal 200

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
      res.statusCode.should.equal 200

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
      res.statusCode.should.equal 200

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

  it "handles POST /api/books", ->
    books = new fake.Resource "book"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "http://localhost"
      port: port
      path: "/api/books"
      method: "POST"
      (res) -> res.on "end", ->
        res.statusCode.should.equal 200

        all = books.all()
        all.length.should.equal 1
        all[0].name.should.equal "foobar"

    req.write JSON.stringify name: "foobar"
    req.end()

  it "handles PUT /api/books/:id", ->
    books = new fake.Resource "book"
      .add name: "foo"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "http://localhost"
      port: port
      path: "/api/books/1"
      method: "PUT"
      (res) -> res.on "end", ->
        res.statusCode.should.equal 200

        all = books.all()
        all.length.should.equal 1
        all[0].name.should.equal "foobar"

    req.write JSON.stringify name: "foobar"
    req.end()

  it "handles DELETE /api/books/:id", ->
    books = new fake.Resource "book"
      .add name: "foo"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "http://localhost"
      port: port
      path: "/api/books/1"
      method: "DELETE"
      (res) -> res.on "end", ->
        res.statusCode.should.equal 200

        all = books.all()
        all.length.should.equal 0

    req.end()

describe "registered resources", ->
  it "can still be renamed", ->
    books = new fake.Resource "book"
      .add name: "foo"
      .add name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    books.name "foo"

    complete = (res) ->
      res.statusCode.should.equal 200
      res.on 'data', ->
      res.on 'end', ->

    http.get "http://localhost:#{port}/api/foos", complete
    http.get "http://localhost:#{port}/api/foos/1", complete
