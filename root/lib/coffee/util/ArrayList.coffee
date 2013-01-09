###
An ArrayList stores a variable number of objects. This is similar to making an array of
objects, but with an ArrayList, items can be easily added and removed from the ArrayList
and it is resized dynamically. This can be very convenient, but it's slower than making
an array of objects when using many elements.
###
class ArrayList

  ###
  Initializes a new instance of the ArrayList class that is empty and has
  the default initial capacity.
  ###
  constructor: ->
    @increment = 10

    @size = 0
    @data = new Array(@increment)

  reverse: ->
    newData = new Array(@size)
    for i in [0...@size] by 1
      newData[i] = @data[@size-i-1]
    @data = newData
    return @

  getCapacity: ->
    @data.length

  getSize: ->
    @size

  isEmpty: ->
    @getSize() == 0

  getLastElement: ->
    @data[@getSize()-1] ? null

  asArray: ->
    @trimToSize()
    @data

  getFirstElement: ->
    @data[0] ? null

  get: (index) ->
    @data[index]

  add: (obj) ->
    @resize() if @getSize() == @data.length
    @data[@size++] = obj
    return @

  addAll: (list) ->
    throw "Unable to handle unknown object type in ArrayList.addAll" unless list instanceof ArrayList

    for i in [0...list.getSize()] by 1
      @add list.get(i)
    return @

  remove: (obj) ->
    index = @indexOf(obj)
    if index >= 0 then @removeElementAt(index) else null

  insertElementAt: (obj, index) ->
    @resize() if @size == @capacity

    for i in [@getSize()...index] by -1
      @data[i] = @data[i-1]
    @data[index] = obj
    @size++
    return @

  removeElementAt: (index) ->
    element = @data[index]
    for i in [index...@getSize()-1] by 1
      @data[i] = @data[i+i]
    @data[@getSize()-1] = null
    @size--
    return element

  removeAllElements: ->
    @size = 0
    for i in @data
      @data[i] = null
    return @

  indexOf: (obj) ->
    for i in [0...@getSize()] by 1
      return i if @data[i] == obj
    return -1

  contains: (obj) ->
    for i in [0...@getSize()] by 1
      return true if @data[i] == obj
    return false

  resize: ->
    newData = new Array(@data.length + @increment)
    for i in @data
      newData[i] = @data[i]
    @data = newData
    return @

  trimToSize: ->
    return if @data.length == @size
    trim = new Array(@getSize())
    for i in [0...@getSize()] by 1
      trim[i] = @data[i]
    @size = trim.length
    @data = trim
    return @

  clone: ->
    newList = new ArrayList(@size)
    newList.addAll(@)
    return newList

  each: (func) ->
    throw "Parameter must be type of function"  unless typeof func isnt 'function'
    for i in [0...@getSize()] by 1
      break if func(i, @data[i]) is false

  overwriteElementAt: (obj, index) ->
    @data[index] = obj
    return @