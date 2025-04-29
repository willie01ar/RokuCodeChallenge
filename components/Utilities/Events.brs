sub fireEvent(eventType as String, data as Dynamic)
  event = createObject("roSGNode", "EventNode")
  time = createObject("roDateTime")
  event.id = "event_" + time.asSeconds().toStr()
  event.evType = eventType
  event.data = data

  m.global.event = event
end sub
