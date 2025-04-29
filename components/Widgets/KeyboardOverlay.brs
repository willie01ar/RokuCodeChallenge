sub init()
  m.background = m.top.findNode("background")
  m.fadeInAnimation = m.top.findNode("fadeInAnimation")

  m.content = m.top.findNode("content")
  m.keyboard = m.top.findNode("keyboard")
  m.actionButton = m.top.findNode("actionButton")
  m.actionButton.observeField("buttonSelected", "onActionButtonPressed")
  m.actionName = m.top.findNode("actionName")

  m.keyboard.showTextEditBox = false
  m.keyboard.observeField("text", "onKeyboardTextChanged")

  m.actionButton.text = m.actionName
  m.top.observeField("visible", "onVisibleChanged")
  
end sub

function configure()
  config = m.top.config
  translation = config.translation
  if translation <> invalid
    m.top.translation = translation
  end if 

  actionName = config.actionName
  if actionName <> invalid 
    m.actionButton.text = actionName
    m.actionButton.iconUri = ""
  end if 

  m.background.width = m.top.boundingRect().width
  m.background.height = getNodePosition(m.actionButton)[1] - 20
  actionButtonXTranslation = ( m.background.width - m.actionButton.boundingRect().width) / 2
 
  m.actionButton.translation = [actionButtonXTranslation, 0]

  m.fadeInAnimation.control = "start"

  m.keyboard.setFocus(true)
end function 

sub onKeyboardTextChanged()
  m.top.searchText = m.keyboard.text
end sub

sub onActionButtonPressed() 
  m.top.keyboardClosed = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  if key = "down" and not m.keyboard.hasFocus()
    m.actionButton.setFocus(true)
    return true
  else if key = "up" and m.actionButton.hasFocus() 
    m.keyboard.setFocus(true)
    return true
  end if 

  return false
end function
