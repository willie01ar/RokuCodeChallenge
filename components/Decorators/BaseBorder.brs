sub init()
    m.topBorder = m.top.findNode("topBorder")
    m.rightBorder = m.top.findNode("rightBorder")
    m.bottomBorder = m.top.findNode("bottomBorder")
    m.leftBorder = m.top.findNode("leftBorder")
end sub

sub updateBorder()
    m.topBorder.height = m.borderSize
    m.rightBorder.width = m.borderSize
    m.bottomBorder.height = m.borderSize
    m.leftBorder.width = m.borderSize
end sub

function setBorderAttributes(params as object)
    tileWidth = params.width
    tileHeight = params.height

    if tileHeight = invalid then
        tileHeight = m.height
    end if

    if m.borderSize <> invalid and m.topBorder <> invalid then
        updateWidth(tileWidth)
        updateHeight(tileHeight)

        if isBlank(params.color) then
            color = Colors_FocusRect()
        else
            color = params.color
        end if

        updateColor(color)
    end if
end function

sub updateWidth(newWidth as float)
    m.rightBorder.translation = [newWidth, 0]
    newWidth += m.borderSize
    m.topBorder.width = newWidth
    m.bottomBorder.width = newWidth
end sub

sub updateHeight(newHeight as float)
    m.bottomBorder.translation = [0, newHeight]
    newHeight += m.borderSize
    m.rightBorder.height = newHeight
    m.leftBorder.height = newHeight
end sub

sub updateColor(newColor as string)
    m.topBorder.color = newColor
    m.rightBorder.color = newColor
    m.bottomBorder.color = newColor
    m.leftBorder.color = newColor
end sub
