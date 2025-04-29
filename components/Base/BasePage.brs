'The idea of this is that all components will inherit from it so
'that reusable code can be passed down. There are some open
'questions around what should go into it.
sub init()
  m.top.observeField("eventResults", "handleEventResults")
  m.top.observeField("focusedChild", "onFocusChanged")
  m.top.observeField("visible", "onVisibilityChanged")

  m.name = "BasePage"
  generatePageId()

end sub

Function generatePageId()
    m.pageName = m.top.subType()
    time = CreateObject("roDateTime")
    m.top.id = m.pageName + "_" + time.asSeconds().toStr() + time.getMilliseconds().toStr()
End Function

function isTopPage()
  rootScene = getTopParent(m.top)
  return rootScene.topPageId = m.top.id
end function

function getTopParent(node)
  if node = invalid or node.getParent() = invalid then
      return node
  end if

  while node <> invalid and node.getParent() <> invalid
      node = node.getParent()
  end while

  return node
end function

sub handleEventResults()
  ConsoleLog().error("OVERRIDE THIS FUNCTION")
end sub

' Called before current page is removed from stack
sub doCleanUp()
  ConsoleLog().debug("OVERRIDE THIS FUNCTION")
end sub