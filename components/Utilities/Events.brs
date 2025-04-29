sub fireEvent(eventType as String, data = {} as Object)
  event = createObject("roSGNode", "EventNode")
  time = createObject("roDateTime")
  event.id = "event_" + time.asSeconds().toStr()
  event.evType = eventType
  event.data = data
  'need to copy out the queue to be able to change m.global assocarray
  queue = m.global.eventQueue
  queue.queue.push(event)
  m.global.eventQueue = queue
end sub