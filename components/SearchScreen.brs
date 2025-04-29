sub init()
  print "SearchScreen initialized"
  m.spinner = m.top.findNode("spinner")
  m.spinner.poster.uri = "pkg:/images/busyspinner_hd.png"
  m.searchBoxFocus = m.top.findNode("searchBoxFocus")
  ' m.searchLabel = m.top.findNode("searchLabel")
  m.searchField = m.top.findNode("searchField")
  m.searchField.observeField("focused","onSearchBoxFocusChange")
  m.resultsList = m.top.findNode("resultsList")
  m.loadMoreButton = m.top.findNode("loadMoreButton")
  m.movieTitle = m.top.findNode("movieTitle")
  m.movieYear = m.top.findNode("movieYear")
  m.moviePlot = m.top.findNode("moviePlot")
  m.detailPane = m.top.findNode("detailPane")
  m.detailPane.visible = false

  m.currentPage = 1

  m.loadMoreButton.observeField("buttonSelected", "onLoadMorePressed")
  m.resultsList.observeField("rowItemSelected","onItemSelected")
  ' m.searchLabel.setFocus(true)

  m.resultsList.content = createSkeletonContent()
  m.hasSkeleton = true 
  setupTextEditFocusRect()
end sub

function setupTextEditFocusRect()
  m.searchBoxFocus.callFunc("setBorderAttributes", {
    width: m.searchField.boundingRect().width + 6
    height: m.searchField.boundingRect().height + 8
    color: Colors_FocusRect()
  })
  setSearchFieldFocus(true)
end function 

function onKeyEvent(key as String, press as Boolean) as Boolean
  if press then 
    if key = "OK" and m.searchField.hasFocus()
      openKeyboardOverlay()
      return true
    end if
    if key="up" and m.resultsList.hasFocus()
      setSearchFieldFocus(true)
      return true
    end if 
  end if
  return false
end function

sub onSearchBoxFocusChange(event as object)
  focused = event.getData()
  if focused 
    m.searchBoxFocus.visible = true
  else 
    m.searchFoxFocus.visible = false
  end if 
end sub 

sub openKeyboardOverlay()
  m.keyboardOverlay = createObject("roSGNode", "KeyboardOverlay")
  m.keyboardOverlay.observeField("searchText", "onSearchTextChange")
  m.keyboardOverlay.observeField("keyboardClosed", "onKeyboardClosed")
  m.top.appendChild(m.keyboardOverlay)

  searchFieldPosition = getNodePosition(m.searchField)

  keyboardOverlayConfig = {
    translation: [searchFieldPosition[0], searchFieldPosition[1] + 50],
    actionName: "Search"
  }
  m.keyboardOverlay.config = keyboardOverlayConfig
end sub

sub onSearchTextChange(event as Object)
  newText = event.getData()
  if newText <> invalid
    m.searchField.text = newText
  end if
end sub

sub closeKeyboardOverlay()
  m.keyboardOverlay.visible = false
  m.top.removeChild(m.keyboardOverlay)
  m.keyboardOverlay = invalid
end sub 

sub onKeyboardClosed()
  closeKeyboardOverlay()
  performSearch(m.searchField.text, m.currentPage)
end sub 

sub performSearch(query as String, page as Integer)
  m.spinner.visible = true
  setSearchFieldFocus(false)
  m.resultsList.setFocus(true)
  
  m.searchTask = createObject("roSGNode","OMDbSearchTask")
  m.searchTask.query = query
  m.searchTask.page = page
  m.searchTask.observeField("output","onSearchResults")
  m.searchTask.control = "RUN"
end sub

function onSearchResults(event as object)
  m.spinner.visible = false
  results = event.getData()
  if results.succeeded
    m.hasSkeleton = false
    m.resultsList.content = results.content
  else 
    presentError(results)
  end if 

  m.searchTask = invalid
end function

sub onLoadMorePressed()
  m.currentPage += 1
  performSearch(m.top.searchQuery, m.currentPage)
end sub

sub onItemSelected(event as Object)
  rowItemSelected = event.getData()
  itemSelected = m.resultsList.content.getChild(rowItemSelected[0]).getChild(rowItemSelected[1])
  if itemSelected <> invalid 
   fireEvent("navigate",{direction: "forward", pageType:"DetailScreen", payload: itemSelected})
  else 
    ConsoleLog().error("Unable to retrieve content")
  end if 
end sub

function createSkeletonContent() as object 
  rootNode = createObject("roSGNode", "ContentNode")
  rowNode = createObject("roSGNode", "ContentNode")

  for i=1 to 4 
    itemNode = createObject("roSGNode", "MovieContent")
    itemNode.posterUri = "pkg:/images/placeholder_tile.png"
    rowNode.appendChild(itemNode)
  end for 

  rootNode.appendChild(rowNode)
  return rootNode
end function 

function presentError(result as object)
  m.errorDialog = createObject("roSGNode","MessageDialog")
  m.errorDialog.title = "There is a problem with your search"
  m.errorDialog.message = [result.errorString]
  m.errorDialog.buttons = ["Close"]
  m.top.appendChild(m.errorDialog)
  m.errorDialog.setFocus(true)
  m.errorDialog.observeField("close","onErrorDialogClose")
end function 

sub onErrorDialogClose()
  print "onErrorDialogClose.... "
  m.errorDialog.visible = false
  m.top.removeChild(m.errorDialog)
  m.errorDialog = invalid
  setSearchFieldFocus(true)
end sub 

sub setSearchFieldFocus(focus as boolean)
  m.searchField.setFocus(focus)
  m.searchBoxFocus.visible = focus
end sub

sub returnFocus()
  'what we do when get focus
  if m.resultsList.content.getChild(0).getChildCount() > 0 and not m.hasSkeleton 
    m.resultsList.setFocus(true)
  else
    setSearchFieldFocus(true)
  end if  
end sub 