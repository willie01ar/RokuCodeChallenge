sub init()
  m.player = m.top.findNode("player")
  m.player.enableUI = true
end sub

sub onPayloadChange(event as object)
  m.top.setFocus(true)
  data = event.getData()
  if data <> invalid 
    m.player.content = data
    m.player.control = "play"
  else 
    ConsoleLog().error("No video data")
  end if
end sub 

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if key="OK"
      closePlayer()
      return true
    end if 
  end if
  return false
end function

sub closePlayer()
  m.player.control = "stop"
  fireEvent("navigate", {direction: "back"})
end sub 

sub handleEventResults()
  'no-op 
end sub

sub doCleanUp()
  m.player.control = "stop"
end sub

sub exitPage()
  m.player.control = "stop"
 
end sub 

sub returnFocus()
  'no-op
end sub 