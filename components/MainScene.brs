sub init()
  ' NOTE:
  ' The "event" node is the entry point for events
  ' For now, there is only one type of event "navigate", if more events types are added in the future
  ' The implementation should consider adding an event queue and a mechanism to process the events to avoid contention and or 
  ' race conditions
  '
  m.global.addField("event", "node", true)
  m.global.observeField("event", "handleEvent")
  
  addNavLayer(m.top.findNode("NavGroup"))

  ' Start with the first screen
  fireEvent("navigate",{direction: "forward", pageType:"SearchScreen", payload: {} })
end sub

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