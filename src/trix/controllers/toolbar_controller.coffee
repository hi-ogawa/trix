{handleEvent, triggerEvent, findClosestElementFromNode} = Trix

class Trix.ToolbarController extends Trix.BasicObject
  actionButtonSelector = "button[data-trix-action]"
  attributeButtonSelector = "button[data-trix-attribute]"
  toolbarButtonSelector = [actionButtonSelector, attributeButtonSelector].join(", ")
  dialogSelector = ".dialog[data-trix-dialog]"
  activeDialogSelector = "#{dialogSelector}.active"
  dialogButtonSelector = "#{dialogSelector} input[data-trix-method]"
  dialogInputSelector = "#{dialogSelector} input[type=text], #{dialogSelector} input[type=url], #{dialogSelector} input[type=radio]"

  constructor: (@element) ->
    @attributes = {}
    @actions = {}
    @resetDialogInputs()

    handleEvent "mousedown", onElement: @element, matchingSelector: actionButtonSelector, withCallback: @didClickActionButton
    handleEvent "mousedown", onElement: @element, matchingSelector: attributeButtonSelector, withCallback: @didClickAttributeButton
    handleEvent "click", onElement: @element, matchingSelector: toolbarButtonSelector, preventDefault: true
    handleEvent "click", onElement: @element, matchingSelector: dialogButtonSelector, withCallback: @didClickDialogButton
    handleEvent "keydown", onElement: @element, matchingSelector: dialogInputSelector, withCallback: @didKeyDownDialogInput

  # Event handlers

  didClickActionButton: (event, element) =>
    @delegate?.toolbarDidClickButton()
    event.preventDefault()
    actionName = getActionName(element)

    if @getDialog(actionName)
      @toggleDialog(actionName)
    else
      @delegate?.toolbarDidInvokeAction(actionName)

  didClickAttributeButton: (event, element) =>
    @delegate?.toolbarDidClickButton()
    event.preventDefault()
    attributeName = getAttributeName(element)

    if @getDialog(attributeName)
      @toggleDialog(attributeName)
    else
      @delegate?.toolbarDidToggleAttribute(attributeName)

    @refreshAttributeButtons()

  didClickDialogButton: (event, element) =>
    dialogElement = findClosestElementFromNode(element, matchingSelector: dialogSelector)
    method = element.getAttribute("data-trix-method")
    @[method].call(this, dialogElement)

  didKeyDownDialogInput: (event, element) =>
    if event.keyCode is 13 # Enter key
      event.preventDefault()
      attribute = element.getAttribute("name")
      dialog = @getDialog(attribute)
      @setAttribute(dialog)
    if event.keyCode is 27 # Escape key
      event.preventDefault()
      @hideDialog()

  # Action buttons

  updateActions: (@actions) ->
    @refreshActionButtons()

  refreshActionButtons: ->
    @eachActionButton (element, actionName) =>
      element.disabled = @actions[actionName] is false

  eachActionButton: (callback) ->
    for element in @element.querySelectorAll(actionButtonSelector)
      callback(element, getActionName(element))

  # Attribute buttons

  updateAttributes: (@attributes) ->
    @refreshAttributeButtons()

  refreshAttributeButtons: ->
    @eachAttributeButton (element, attributeName) =>
      element.disabled = @attributes[attributeName] is false
      if @attributes[attributeName] or @dialogIsVisible(attributeName)
        element.classList.add("active")
      else
        element.classList.remove("active")

  eachAttributeButton: (callback) ->
    for element in @element.querySelectorAll(attributeButtonSelector)
      callback(element, getAttributeName(element))

  applyKeyboardCommand: (keys) ->
    keyString = JSON.stringify(keys.sort())
    for button in @element.querySelectorAll("[data-trix-key]")
      buttonKeys = button.getAttribute("data-trix-key").split("+")
      buttonKeyString = JSON.stringify(buttonKeys.sort())
      if buttonKeyString is keyString
        triggerEvent("mousedown", onElement: button)
        return true
    false

  # Dialogs

  dialogIsVisible: (dialogName) ->
    if element = @getDialog(dialogName)
      element.classList.contains("active")

  toggleDialog: (dialogName) ->
    if @dialogIsVisible(dialogName)
      @hideDialog()
    else
      @showDialog(dialogName)

  showDialog: (dialogName) ->
    @hideDialog()
    @delegate?.toolbarWillShowDialog()

    element = @getDialog(dialogName)
    element.classList.add("active")

    for disabledInput in element.querySelectorAll("input[disabled]")
      disabledInput.removeAttribute("disabled")

    if attributeName = getAttributeName(element)
      attributeValue = @attributes[attributeName] ? ""
      setInputValueForDialog(element, attributeName, attributeValue)

    @delegate?.toolbarDidShowDialog(dialogName)

  setAttribute: (dialogElement) ->
    attributeName = getAttributeName(dialogElement)
    input = getInputForDialog(dialogElement, attributeName)
    if input.willValidate and not input.checkValidity()
      input.classList.add("validate")
      input.focus()
    else
      @delegate?.toolbarDidUpdateAttribute(attributeName, input.value)
      @hideDialog()

  removeAttribute: (dialogElement) ->
    attributeName = getAttributeName(dialogElement)
    @delegate?.toolbarDidRemoveAttribute(attributeName)
    @hideDialog()

  hideDialog: ->
    if element = @element.querySelector(activeDialogSelector)
      element.classList.remove("active")
      @resetDialogInputs()
      @delegate?.toolbarDidHideDialog(getDialogName(element))

  resetDialogInputs: ->
    for input in @element.querySelectorAll(dialogInputSelector)
      input.setAttribute("disabled", "disabled")
      input.classList.remove("validate")

  getDialog: (dialogName) ->
    @element.querySelector(".dialog[data-trix-dialog=#{dialogName}]")

  getInputsForDialog = (element, attributeName) ->
    attributeName ?= getAttributeName(element)
    [element.querySelectorAll("input[name='#{attributeName}']")...]

  getInputForDialog = (element, attributeName) ->
    inputs = getInputsForDialog(element, attributeName)
    if inputs.length is 1
      return inputs[0]
    else
      return input for input in inputs when input.checked

  setInputValueForDialog = (element, attributeName, attributeValue) ->
    inputs = getInputsForDialog(element, attributeName)
    if inputs.length is 1
      inputs[0].value = attributeValue
      inputs[0].select()
    else
      input.checked = true for input in inputs when input.value is attributeValue
    attributeValue

  # General helpers

  getActionName = (element) ->
    element.getAttribute("data-trix-action")

  getAttributeName = (element) ->
    element.getAttribute("data-trix-attribute")

  getDialogName = (element) ->
    element.getAttribute("data-trix-dialog")
