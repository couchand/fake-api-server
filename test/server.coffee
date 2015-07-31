# server unit tests

chai = require 'chai'
chai.should()

Server = require '../lib/server'

describe "server", ->
  it "errors on multiple listen calls", ->
    server = new Server()
    server.listen()

    (-> server.listen()).should.throw /listen/

  it "errors on multiple listen calls with different ports", ->
    server = new Server()
    server.listen 3001

    (-> server.listen 3002).should.throw /listen/
