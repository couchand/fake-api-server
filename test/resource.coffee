# resource test

chai = require 'chai'
chai.should()

Resource = require '../lib/resource'

describe "Resource", ->
  resourceName = "Foobar"
  r = beforeEach -> r = new Resource resourceName

  describe "idAttribute", ->
    it "defaults to 'id'", ->
      r.idAttribute().should.equal 'id'

    it "can be changed", ->
      r.idAttribute 'potato'
      r.idAttribute().should.equal 'potato'

    it "chains", ->
      r.idAttribute('charity').should.equal r

  describe "idFactory", ->
    it "defaults to increment", ->
      factory = r.idFactory()
      factory.should.be.a 'function'

      factory().should.equal 1
      r.add {}
      factory().should.equal 2
      r.add {}
      factory().should.equal 3
      r.add {}
      factory().should.equal 4

    it "can be changed", ->
      r.idFactory -> 255
      factory = r.idFactory()

      factory().should.equal 255
      r.add {}
      factory().should.equal 255
      r.add {}
      factory().should.equal 255
      r.add {}
      factory().should.equal 255

    it "chains", ->
      r.idFactory(-> 1).should.equal r

  describe "name", ->
    it "returns the name", ->
      r.name().should.equal resourceName

    it "can be changed", ->
      r.name "Bill"
      r.name().should.equal "Bill"

    it "chains", ->
      r.name("Bill").should.equal r

  describe "pluralName", ->
    it "pluralizes the name", ->
      r.pluralName().should.equal "#{resourceName}s"

    it "can be changed", ->
      r.pluralName "Moose"
      r.pluralName().should.equal "Moose"

    it "chains", ->
      r.pluralName("Bill").should.equal r

  describe "add", ->
    it "adds records", ->
      r.add sparkles = {}

      records = r.all()
      records.length.should.equal 1
      records.should.contain sparkles

  describe "all", ->
    it "returns the records", ->
      r.add moe = {}
        .add larry = {}
        .add curly = {}

      all = r.all()
      all.length.should.equal 3
      all.should.contain moe
      all.should.contain larry
      all.should.contain curly

  describe "find", ->
    lisa = beforeEach ->
      r.add bart = {}
        .add lisa = {}
        .add maggie = {}
        .add homer = {}
        .add marge = {}

    it "finds a record by id", ->
      r.find(lisa.id).should.equal lisa

    it "returns false when no record found", ->
      r.find(935).should.be.false

  describe "update", ->
    it "updates a record by id", ->
      r.add bluebird = {}

      r.update bluebird.id,
        name: "Sammy"
        color: "blue"

      bluebird.name.should.equal "Sammy"
      bluebird.color.should.equal "blue"

    it "returns the updated record", ->
      r.add firefly = {}
      r.update(firefly.id, name: "Mal").should.equal firefly

    it "returns false when no record found", ->
      r.update(935, name: "Casper").should.be.false

  describe "remove", ->
    it "removes a record by id", ->
      r.add bart = {}
        .add lisa = {}
        .add maggie = {}
        .add homer = {}
        .add marge = {}

      r.remove homer.id

      r.all().length.should.equal 4
      r.all().should.contain bart
      r.all().should.contain lisa
      r.all().should.contain maggie
      r.all().should.contain marge

    it "returns true", ->
      r.add neutrino = {}
      r.remove(neutrino.id).should.be.true

    it "returns false when no record found", ->
      r.remove(935).should.be.false
