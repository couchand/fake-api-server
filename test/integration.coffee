# integration tests for server

chai = require 'chai'
chai.should()

fake = require '../lib'
http = require 'http'

_port = 6000
nextPort = -> _port = _port + 1

describe "server", ->
  it "handles index requests", (done) ->
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

        done()

  it "handles GET /api/books", (done) ->
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

        done()

  it "handles GET /api/books/:id", (done) ->
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

        done()

  it "handles 404 on GET /api/books/:id", (done) ->
    books = new fake.Resource "book"
      .add name: "foo"
      .add name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/books/8383", (res) ->
      res.statusCode.should.equal 404
      done()

  it "handles POST /api/books", (done) ->
    books = new fake.Resource "book"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/books"
      method: "POST"
      (res) ->
        res.statusCode.should.equal 200
        res.on 'data', ->
        res.on 'end', ->
          res.statusCode.should.equal 200

          all = books.all()
          all.length.should.equal 1
          all[0].name.should.equal "foobar"
          done()

    req.setHeader "Content-Type", "application/json"
    req.write JSON.stringify name: "foobar"
    req.end()

  it "handles PUT /api/books/:id", (done) ->
    books = new fake.Resource "book"
      .add name: "foo"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/books/1"
      method: "PUT"
      (res) ->
        res.statusCode.should.equal 200
        res.on "data", ->
        res.on "end", ->
          res.statusCode.should.equal 200

          all = books.all()
          all.length.should.equal 1
          all[0].name.should.equal "foobar"
          done()

    req.setHeader "Content-Type", "application/json"
    req.write JSON.stringify name: "foobar"
    req.end()

  it "handles DELETE /api/books/:id", (done) ->
    books = new fake.Resource "book"
      .add name: "foo"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/books/1"
      method: "DELETE"
      (res) ->
        res.statusCode.should.equal 200
        res.on "data", ->
        res.on "end", ->
          all = books.all()
          all.length.should.equal 0
          done()

    req.end()

describe "registered resources", ->
  it "can still be renamed", (done) ->
    books = new fake.Resource "books"
      .add name: "foo"
      .add name: "bar"
      .add name: "baz"

    server = new fake.Server()
      .register books
      .listen port = nextPort()

    books.name "cat"

    total = 5
    complete = (res) ->
      res.statusCode.should.equal 200
      res.on 'data', ->
      res.on 'end', ->
        if (total -= 1) is 0
          done()

    http.get "http://localhost:#{port}/api/cats", complete
    http.get "http://localhost:#{port}/api/cats/1", complete

    req = http.request
      host: "localhost"
      port: port
      path: "/api/cats"
      method: "POST"
      complete
    req.setHeader "Content-Type", "application/json"
    req.write JSON.stringify name: "foobar"
    req.end()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/cats/2"
      method: "PUT"
      complete
    req.setHeader "Content-Type", "application/json"
    req.write JSON.stringify name: "foobar"
    req.end()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/cats/1"
      method: "DELETE"
      complete
    req.end()
