sub init()
  m.poster = m.top.findNode("poster")
  'Note: 
  ' Let's check on the loading status of the poster to replace if with a placeholder if it fails.
  ' A good improvement for this is to build a RetryablePoster object with this functionality built in.
  '
  m.poster.observeField("loadStatus","onPosterLoadStatus")
  m.titleLabel = m.top.findNode("titleLabel")
  m.itemMask = m.top.findNode("itemMask")

  m.top.observeField("posterUrl", "updatePoster")
  m.top.observeField("title", "updateTitle")
end sub

sub showContent()
  itemContent = m.top.itemContent
  m.poster.uri = itemContent.posterUri 
  m.titleLabel.text = itemContent.title 
end sub

sub showFocus()
  scale = 1 + (m.top.focusPercent * 0.08)
  m.poster.scale = [scale, scale]
end sub 

sub showRowFocus()
  m.itemMask.opacity = 0.75 - (m.top.rowFocusPercent * 0.75)
  m.titleLabel.opacity = m.top.rowFocusPercent
end sub


sub updatePoster()
  if m.top.posterUrl <> ""
    m.poster.uri = m.top.posterUrl
  end if
end sub

sub updateTitle()
  m.titleLabel.text = m.top.title
end sub

sub onPosterLoadStatus(event as object)
  status = event.getData()
  ConsoleLog().warn("Poster load status: "+status)
  if status = "failed" 
    m.poster.uri = "pkg:/images/Failed_to_load.png"
  end if
end sub 