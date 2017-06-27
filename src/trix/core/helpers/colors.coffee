Trix.extend
  normalizeColor: (color) ->
    return "" unless color
    if isNamedColor(color)
      color = getRGBAColor(color)
    getBrowserColor(color)

getRGBAColor = (color) ->
  canvas = document.createElement("canvas")
  canvas.height = canvas.width = 1
  context = canvas.getContext("2d")
  context.fillStyle = color
  context.fillRect(0, 0, 1, 1)
  [r, g, b, a] = context.getImageData(0, 0, 1, 1).data
  a = Number((a / 255).toFixed(2))
  "rgba(#{r}, #{g}, #{b}, #{a})"

getBrowserColor = (color) ->
  element = document.createElement("span")
  element.style.color = color
  element.style.color

isNamedColor = (color) ->
  /^[a-z]+$/i.test(color)
