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
    options: ["orangered", "mediumslateblue", "mediumseagreen"]
    parser: (element) ->
      if color = element.style.color?.toLowerCase()
        if color in @options
          color
  backgroundColor:
    options: ["yellow", "pink", "aqua"]
    parser: (element) ->
      if color = element.style.backgroundColor?.toLowerCase()
        if color in @options
          color
  frozen:
    style: { "backgroundColor": "highlight" }
