# fake api resource

class Resource
  constructor: (@_name) ->
    @_records = []
    @_idAttribute = "id"
    @_idFactory   = =>
      1 + Math.max 0,
        Math.max.apply Math, (d[@_idAttribute] for d in @_records)

  idAttribute: ->
    if arguments.length is 0
      @_idAttribute
    else
      @_idAttribute = arguments[0]
      this

  idFactory: ->
    if arguments.length is 0
      @_idFactory
    else
      @_idFactory = arguments[0]
      this

  name: ->
    if arguments.length is 0
      @_name
    else
      @_name = arguments[0]
      this

  pluralName: ->
    if arguments.length is 0
      if @_pluralName
        @_pluralName
      else
        "#{@_name}s"
    else
      @_pluralName = arguments[0]
      this

  all: ->
    @_records

  add: (record) ->
    record[@_idAttribute] = @_idFactory()
    @_records = @_records.concat [record]
    this

  find: (id) ->
    record = @_records.filter (d) =>
      "#{d[@_idAttribute]}" is "#{id}"
    if record.length then record[0] else no

  update: (id, updates) ->
    record = @find id
    return no unless record
    for name, value of updates when name isnt @_idAttribute
      record[name] = value
    record

  remove: (id) ->
    record = @find id
    return no unless record
    @_records = @_records.filter (d) =>
      "#{d[@_idAttribute]}" isnt "#{id}"
    yes

module.exports = Resource
