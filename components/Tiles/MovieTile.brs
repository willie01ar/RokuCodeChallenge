sub init()
  m.poster = m.top.findNode("poster")
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