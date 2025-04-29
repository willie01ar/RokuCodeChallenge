sub init()
  m.poster = m.top.findNode("poster")
  m.titleLabel = m.top.findNode("titleLabel")
  m.yearLabel = m.top.findNode("yearLabel")
  m.movieType = m.top.findNode("movieType")
  m.playButton = m.top.findNode("playButton")
  m.backButton = m.top.findNode("backButton")

  ' Observe play button click
  m.playButton.observeField("buttonSelected", "onPlayButtonSelected")
  m.backButton.observeField("buttonSelected", "onBackButtonSelected")

end sub

sub onPayloadChange(event as object)
  data = event.getData()
  if data <> invalid 
    m.poster.uri = data.posterUri
    m.titleLabel.text = data.title
    m.yearLabel.text = "Year: " + data.year
    m.movieType.text = data.type
  end if 
end sub 

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then
    if key = "left" and m.playButton.hasFocus()
      m.backButton.setFocus(true)
      return true
    end if
    if key="right" and m.backButton.hasFocus()
      m.playButton.setFocus(true)
      return true
    end if 
  end if
  return false
end function

sub onBackButtonSelected()
  fireEvent("navigate", {direction: "back"})
end sub

sub onPlayButtonSelected()
  ConsoleLog().warn("Play button pressed")
  videoContent = createObject("roSGNode","ContentNode")
  videoContent.url = "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8"
  videoContent.title = "Test Video"
  videoContent.streamformat = "hls"
  fireEvent("navigate",{direction: "forward", pageType:"VideoPlayer", payload: videoContent})
end sub

sub exitPage()
  ' Do any work needed when exiting this page
end sub

sub returnFocus()
  'what we do when get focus
  m.playButton.setFocus(true)
end sub 

sub doCleanup()
   ' Do any work needed before this screen gets removed from the nav stack
end sub 

sub handleEventResults()
  'no-op 
end sub
