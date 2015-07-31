# integration tests for server

chai = require 'chai'
chai.should()

fake = require '../lib'
http = require 'http'
express = require 'express'

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

  it "handles 404 on GET /api/idontexist", (done) ->
    server = new fake.Server()
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/idontexist", (res) ->
      res.statusCode.should.equal 404
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

  it "handles 404 on GET /api/idontexist/:id", (done) ->
    server = new fake.Server()
      .listen port = nextPort()

    http.get "http://localhost:#{port}/api/idontexist/1337", (res) ->
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

  it "handles 404 on POST /api/idontexist", (done) ->
    server = new fake.Server()
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/idontexist"
      method: "POST"
      (res) ->
        res.statusCode.should.equal 404
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

  it "handles 404 on PUT /api/idontexist/:id", (done) ->
    server = new fake.Server()
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/idontexist/1"
      method: "PUT"
      (res) ->
        res.statusCode.should.equal 404
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

  it "handles 404 on DELETE /api/idontexist/:id", (done) ->
    server = new fake.Server()
      .listen port = nextPort()

    req = http.request
      host: "localhost"
      port: port
      path: "/api/idontexist/1"
      method: "DELETE"
      (res) ->
        res.statusCode.should.equal 404
        done()

    req.setHeader "Content-Type", "application/json"
    req.write JSON.stringify name: "foobar"
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

describe "use middleware", ->
  describe "loaded after listen", ->
    it "uses middleware for new resources", (done) ->
      called = no
      middleware = (req, res) -> called = yes; res.status(200).end()

      server = new fake.Server()
        .listen port = nextPort()
        .use middleware

      http.get "http://localhost:#{port}/index.html", (res) ->
        res.statusCode.should.equal 200
        called.should.be.true
        done()

    it "is shadowed by the standard routes", (done) ->
      called = no
      middleware = (req, res) -> called = yes; res.status(200).end()

      server = new fake.Server()
        .listen port = nextPort()
        .use middleware

      http.get "http://localhost:#{port}/api", (res) ->
        res.statusCode.should.equal 200
        called.should.be.false
        done()

  describe "loaded before listen", ->
    it "uses middleware for new resources", (done) ->
      called = no
      middleware = (req, res) -> called = yes; res.status(200).end()

      server = new fake.Server()
        .use middleware
        .listen port = nextPort()

      http.get "http://localhost:#{port}/index.html", (res) ->
        res.statusCode.should.equal 200
        called.should.be.true
        done()

    it "shadows the standard routes", (done) ->
      called = no
      middleware = (req, res) -> called = yes; res.status(500).end()

      server = new fake.Server()
        .use middleware
        .listen port = nextPort()

      http.get "http://localhost:#{port}/api", (res) ->
        res.statusCode.should.equal 500
        called.should.be.true
        done()

    it "passes through to the standard routes", (done) ->
      called = no
      middleware = (req, res, next) -> called = yes; next()

      server = new fake.Server()
        .use middleware
        .listen port = nextPort()

      http.get "http://localhost:#{port}/api", (res) ->
        res.statusCode.should.equal 200
        called.should.be.true
        done()

describe "static content", ->
  it "handles 404 GET /integration.coffee without static", (done) ->

    server = new fake.Server()
      .listen port = nextPort()

    http.get "http://localhost:#{port}/integration.coffee", (res) ->
      res.statusCode.should.equal 404
      done()

  it "handles 200 GET /integration.coffee with static", (done) ->

    server = new fake.Server()
      .static __dirname
      .listen port = nextPort()

    http.get "http://localhost:#{port}/integration.coffee", (res) ->
      res.statusCode.should.equal 200
      done()

  it "handles 404 GET /notfound.coffee with static", (done) ->

    server = new fake.Server()
      .static __dirname
      .listen port = nextPort()

    http.get "http://localhost:#{port}/notfound.coffee", (res) ->
      res.statusCode.should.equal 404
      done()
