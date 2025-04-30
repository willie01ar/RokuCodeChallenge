
function init()
  print "Initializing OMDbSearchTask"
  m.top.functionName = "performRequest"
  m.port = createObject("roMessagePort")
end function 


sub performRequest()
  url = "https://www.omdbapi.com/?apikey=6e30f9d9&type=movie&s=" + url_encode(m.top.query) + "&page=" + m.top.page.ToStr()
  print "Searching: "; url

  transfer = CreateObject("roUrlTransfer")
  transfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
  transfer.setUrl(url)
  transfer.setRequest("GET")
  transfer.setPort(m.port)
  responseString = transfer.asyncGetToString()

  msg = wait(5000, m.port)
  if msg = invalid 
    m.top.output = setErrorResponse("Request timed out", 408)
  else if type(msg) = "roUrlEvent"
    if msg.getResponseCode() <> 200
      m.top.output = setErrorResponse("Request error", msg.getResponseCode())
    else 
      responseString = msg.getString()
      if responseString = invalid 
        m.top.output = setErrorResponse("Invalid response from server")
      end if 
      parseResponse(responseString)
    end if 
  end if
end sub

function setErrorResponse(errorString as String, errorCode = 0 as Integer ) as object
  errorResponse = createObject("roSGNode","SearchResponse")
  errorResponse.errorString = errorString
  errorResponse.succeeded = false
  errorResponse.errorCode = errorCode
  return errorResponse
end function 

function setSuccessResponse(content as object) as object
  successResponse = createObject("roSGNode","SearchResponse")
  successResponse.succeeded = true
  successResponse.content = content
  return successResponse
end function 

function parseResponse(responseString as String)

  jsonResponse = ParseJson(responseString)

  if jsonResponse = invalid or jsonResponse?.error <> invalid
    m.top.output = setErrorResponse(jsonResponse?.error)
  else
    rootNode = createObject("roSGNode", "ContentNode")
    rowNode = createObject("roSGNode", "ContentNode")

    for each movie in jsonResponse.Search
      movieNode = createObject("roSGNode", "MovieContent")
      movieNode.title = movie.Title
      if isUrl(movie.Poster)
        movieNode.posterUri = movie.Poster
      else 
        movieNode.posterUri = "pkg:/images/Failed_to_load.png"
      end if 
      movieNode.year = movie.Year
      movieNode.imdbID = movie.imdbID 
      rowNode.appendChild(movieNode)
    end for

    rootNode.appendChild(rowNode)

    m.top.output = setSuccessResponse(rootNode)
  end if 
end function 
