sub init()
  print "MainScene initialized"
  m.searchScreen = createObject("roSGNode", "SearchScreen")
  m.searchScreen.observeField("outputEvent", "onSearchScreenEvent")
  m.top.appendChild(m.searchScreen)
  m.searchScreen.setFocus(true)
end sub

function onSearchScreenEvent(message as object)
  event = message.getData()
  print "Message Received "
  print event
end function 