'Simple gateway for splitting direction. Direction is related to
'the stack. Forward is increased integer in the stack, back is
'decreased.
sub handleNavigation(direction as String, pageType as String, payload as Dynamic, pagesInStack = invalid as Dynamic)
    if direction = "forward" 
        navForward(pageType, payload)
    else if direction = "back" 
        if pageType = "none" 
            if pagesInStack = invalid 
                navBack()
            else
                clearStackUntilPage(pagesInStack, payload)
            end if
        else
            jumpBack(pageType)
        end if
    else if direction = "replace"
        'Prevents a crash when the navStack is invalid and we do a 'replace' navigation action
        if m.navStack <> invalid
            replacePage(pageType, payload)
        else
            ConsoleLog().warn("Navstack invalid. Changing the action to 'forward' to properly intialize it.")
            navForward(pageType, payload)
        end if
    else if direction = "empty"
        emptyStack(payload)
    else
        ConsoleLog().warn("Invalid navigation direction '" + direction + "'")
    end if

end sub

'Cleans the nav-stack until a position sent by parameter
sub clearStackUntilPage(pagesInStack, payload = invalid as object)
    toPage = m.navLayer.findNode(m.navStack[pagesInStack - 1])

    if toPage <> invalid then
        numPagesToPop = getNavStackSize() - pagesInStack

        while numPagesToPop > 0
            popPage()
            numPagesToPop--
        end while

        toPage.opacity = 100
        toPage.visible = true
        if payload <> invalid then
            toPage.payload = payload
        end if
    end if
end sub

sub updatePagePayload(page as object, payload as object)
  if page.hasField("payload") then page.payload = payload
end sub

'Forward is different from back because there is the possibility
'that the page will have not yet been created
sub navForward(pageType as String, payload as Object)
  toPage = CreateObject("roSGNode", pageType)
  toPage.visible = false
  updatePagePayload(toPage, payload)
  pushPage(toPage)

  ' there's only a fromPage if there's at least one screen on stack
  navStackSize = getNavStackSize()
  if navStackSize > 1 then
      fromPage = m.navLayer.findNode(m.navStack[navStackSize - 2])
      fromPage.exitPage = true
      fromPage.visible = false
  end if
  toPage.visible = true
  completeNavForward(toPage)
end sub

'Back assumed that the page has been created since it exists in
'the stack.
sub navBack()
  navStackSize = getNavStackSize()

  if navStackSize > 0 then
      fromPage = m.navLayer.findNode(m.navStack[navStackSize - 1])
      fromPage.exitPage = true

      if navStackSize = 1 then
          toPage = invalid
          completeNavBack(toPage)
      else
          toPage = m.navLayer.findNode(m.navStack[navStackSize - 2])
          fromPage.visible = false
          toPage.opacity = 100
          toPage.visible = true
          toPage.exitPage = false
          completeNavBack(toPage)
      end if
  end if
end sub

'Jump tries to look if the page to jump to exists in navStack,
'then pops the pages until the specified page is at top of navStack
sub jumpBack(pageType as String)
    navStackSize = getNavStackSize()

    if navStackSize > 0
        currentPos = navStackSize - 1
        'Loop through navStack to check if pageType exists on stack
        while currentPos >= 0
            currentId = m.navStack[currentPos]
            if currentId.inStr(pageType) >= 0 then
                exit while
            end if
            currentPos --
        end while

        'If pageType exists on navStack, then removes all the pages that's on top of pageType
        if currentPos >= 0 then
            topPosition = navStackSize - 1
            fromPage = m.navLayer.findNode(m.navStack[topPosition])
            toPage = m.navLayer.findNode(m.navStack[currentPos])
            fromPage.exitPage = true
            fromPage.visible = false
            toPage.opacity = 100
            toPage.visible = true
            ' pop the pages from the top to the destination page
            for i = 1 to topPosition - currentPos
                popPage()
            end for
            handlePageFocus(toPage)
        else
            ConsoleLog().debug("Did not find page in navStack, no page jump performed")
        end if
    end if
end sub

sub handlePageFocus(page, returningFromContextMenu = false as boolean, returningFromDialog = false as boolean)
    ConsoleLog().debug("giving focus to page: " + page.id)
    m.top.topPageId = page.id
    page.returnFocus = { fromContextMenu: returningFromContextMenu, fromDialog: returningFromDialog }
end sub

'Separated out for the navigation to trigger
sub completeNavForward(toPage)
    toPage.setFocus(true)
    handlePageFocus(toPage)
end sub

sub completeNavBack(toPage)
    popPage()
    if toPage <> invalid then
        handlePageFocus(toPage)
    end if
end sub

sub completeReplace(toPage)
    handlePageFocus(toPage)
end sub

'Replace assumes that you're creating the page
sub replacePage(pageType as string, payload as object)
    navStackSize = getNavStackSize()

    fromPage = m.navLayer.findNode(m.navStack[navStackSize - 1])
    fromPage.cleanUp = true
    fromPage.exitPage = true

    toPage = CreateObject("roSGNode", pageType)
    toPage.visible = false

    updatePagePayload(toPage, payload)

    m.navStack[navStackSize - 1] = toPage.id
    m.navLayer.appendChild(toPage)

    toPage.visible = true
    fromPage.visible = false

    m.navLayer.removeChild(fromPage)
    completeReplace(toPage)
end sub

' clears every page on the stack
sub emptyStack(payload as Dynamic)
    while getNavStackSize() > 0
        popPage(true)
    end while
end sub

function getNavStackSize() as integer
    if m.navStack = invalid then
        m.navStack = []
    end if

    return m.navStack.count()
end function

' adds a page id to the stack and the page itself as a child
sub pushPage(page)
    ConsoleLog().debug("loading page: " + page.id)
    if m.navStack = invalid then
        m.navStack = []
    end if
    m.navStack.push(page.id)
    m.navLayer.appendChild(page)
end sub

' removes top page from the stack and removes itself as a child
sub popPage(canPopAllPages = false as boolean)
    ' We don't want to pop every page if a user is hitting the back button repeatedly,
    ' but in some cases (e.g. clearing the stack before navigating forward from profile) we
    ' want to allow it
    if (not canPopAllPages) and (getNavStackSize() = 1) then return

    pageId = m.navStack[getNavStackSize() - 1]
    removePage(pageId)

    '
    ' If we have more pages in the stack we need to restore the hulu logo state of the next page in the stack
    if getNavStackSize() > 0 then
        nextPage = m.navLayer.findNode(m.navStack.peek())
    end if
end sub

' given a page id, removes the id and page component from the stack and scene
sub removePage(pageId)
    page = m.navLayer.findNode(pageId)
    page.cleanUp = true
    if page.exitPage <> true then page.exitPage = true

    ' remove from scene graph
    m.navLayer.removeChild(page)

    ' remove from id stack
    pageIndex = findIndex(pageId, m.navStack)
    m.navStack.delete(pageIndex)
end sub

sub addNavLayer(layer as Dynamic)
    m.navLayer = layer
end sub

function findIndex(element, dataArray) as Integer
  for i = 0 to dataArray.count() - 1
    if dataArray[i] = element then
        return i
    end if
  end for
  return -1
end function 
