sub init()
  m.global.addField("event", "node", true)
  m.global.observeField("event", "handleEvent")
  addNavLayer(m.top.findNode("NavGroup"))

  m.searchScreen = createObject("roSGNode", "SearchScreen")
  m.searchScreen.observeField("outputEvent", "onSearchScreenEvent")
  m.top.appendChild(m.searchScreen)
  m.searchScreen.setFocus(true)
end sub

function onSearchScreenEvent(message as object)
  event = message.getData()
  ConsoleLog().info("Event received in MainScene")
  print event
end function 

function handleEvent()
  ev = m.global.event
  evType = ev.evType
  data = ev.data
  #if ENABLE_DBG
    ConsoleLog().log("handleEvent() event type:" + evType)
  #end if
  if evType = "navigate"
    if data.pageType = invalid 
      data.pageType = "none"
    end if 
    handleNavigation(data.direction, data.pageType, data.payload, data.pagesInStack)
  end if 
end function 