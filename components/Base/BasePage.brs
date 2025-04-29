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
  ' If the page receive data due to a triggered event, this is the place to handle it
  ConsoleLog().error("Subtypes MUST OVERRIDE THIS FUNCTION")
  _ = {}
  _.crash()
end sub

sub doCleanUp()
  ' Do any work needed before this screen gets removed from the nav stack
  ConsoleLog().error("Subtypes OVERRIDE THIS FUNCTION")
  _ = {}
  _.crash()
end sub

sub exitPage()
  ' Do any work needed when exiting the page
  ConsoleLog().error("Subtypes OVERRIDE THIS FUNCTION")
  _ = {}
  _.crash()
end sub 

sub returnFocus()
  ' Do any work needed when getting back focus
  ConsoleLog().error("Subtypes OVERRIDE THIS FUNCTION")
  _ = {}
  _.crash()
end sub 