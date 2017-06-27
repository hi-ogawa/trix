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
    options: new Trix.ColorSet "orangered", "mediumslateblue", "mediumseagreen"
    parser: (element) ->
      @options.get(element.style.color)
  backgroundColor:
    options: new Trix.ColorSet "yellow", "pink", "aqua"
    parser: (element) ->
      @options.get(element.style.backgroundColor)
  frozen:
    style: { "backgroundColor": "highlight" }
