{normalizeColor} = Trix

class Trix.ColorSet
  constructor: (colors...) ->
    @clear()
    @add(color) for color in colors

  add: (color) ->
    color = normalizeColor(color)
    @values.add(color)

  delete: (color) ->
    color = normalizeColor(color)
    @values.delete(color)

  has: (color) ->
    color = normalizeColor(color)
    @values.has(color)

  get: (color) ->
    color = normalizeColor(color)
    color if @has(color)

  clear: ->
    @values = new Set

  forEach: ->
    @values.forEach(arguments...)
