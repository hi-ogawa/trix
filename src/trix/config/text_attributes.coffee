Trix.config.textAttributes =
  bold:
    tagName: "strong"
    inheritable: true
    parser: (element) ->
      style = window.getComputedStyle(element)
      style["fontWeight"] is "bold" or style["fontWeight"] >= 600
  italic:
    tagName: "em"
    inheritable: true
    parser: (element) ->
      style = window.getComputedStyle(element)
      style["fontStyle"] is "italic"
  href:
    groupTagName: "a"
    parser: (element) ->
      {attachmentSelector} = Trix.AttachmentView
      matchingSelector = "a:not(#{attachmentSelector})"
      if link = Trix.findClosestElementFromNode(element, {matchingSelector})
        link.getAttribute("href")
  strike:
    tagName: "del"
    inheritable: true
  color:
    colors: new Trix.ColorSet "#ff2d55","#e55235", "#ec7a3c", "#5856d6", "#009688", "#3cb371"
    styleProperty: "color"
    parser: (element) ->
      @colors.get(element.style.color)
  highlight:
    colors: new Trix.ColorSet "#faf785", "#e8fff5", "#ecf9fd", "#fdf3e6", "#ffe5e5", "#f2f2f2"
    styleProperty: "backgroundColor"
    parser: (element) ->
      @colors.get(element.style.backgroundColor)
  frozen:
    style: { "backgroundColor": "highlight" }
