' Constant colors defined below'
function Colors_Menu() as string
    return "#36CA94"
end function

function Colors_ProgressBarRecording() as string
    return "#FE6666"
end function

function Colors_ProgressBarPlayable() as string
    return "#36CA94"
end function

function Colors_ProgressBarDefault() as string
    return "#FFFFFF"
end function

function Colors_FocusRect() as string
    return "#FFFFFF"
end function

' A value is considered a `color` if it is: a) an #rrggbb format color string,
' or b) an #rrggbbaa format color string. A zero alpha color string, for example
' "#11223300", is a color. An invalid value or a blank string is not a color.
function isColor(s as dynamic) as boolean
    if invalid = s or invalid = getInterface(s, "ifString") then return false
    n = len(s)
    return (n = 7 or n = 9) and left(s, 1) = "#"
end function

' A value is considered `transparent` if it is: a) not a string, b) a blank
' string, or b) an #rrggbbaa format color string with zero alpha, for example
' "#11223300".
function isTransparent(s as dynamic) as boolean
    if invalid = s or invalid = getInterface(s, "ifString") or s.trim() = "" then return true
    return len(s) = 9 and left(s, 1) = "#" and right(s, 2) = "00"
end function

' |               x  |   invalid   |   11223344  |     " "     |  "#112233"  | "#11223300" | "#11223344" |
' | ---------------- | ----------- | ----------- | ----------- | ----------- | ----------- | ----------- |
' |       isColor(x) |   false(1)  |   false(1)  |   false(2)  |   true      |   true      |   true      |
' | isTransparent(x) |   true(3)   |   true(3)   |   true(4)   |   false     |   true(5)   |   false     |
'
'   (1) not a string -> not a color
'   (2) not #rrggbb or #rrggbbaa -> not a color
'   (3) not a string -> transparent
'   (4) blank string -> transparent
'   (5) #rrggbb00 string -> transparent

function colorOr(color as dynamic, fallbackColor as string) as string
    if isColor(color) then return color
    return fallbackColor
end function

function nonTransparentColorOr(color as dynamic, fallbackColor as string) as string
    if isTransparent(color) then return fallbackColor
    return color
end function

function intToColorString(i as integer) as string
    return "#" + int2hex(i)
end function

function toColorString(x as dynamic, fallbackColor = transparent() as string) as string
    if isColor(x) then return x
    if invalid <> x and invalid <> getInterface(x, "ifInt") then return intToColorString(x)
    return fallbackColor
end function

' Returns a canonical transparent color value.
function transparent() as string
    return "#FFFFFF00"
end function

' Returns a canonical white color value, including alpha.
function white() as string
    return "#FFFFFFFF"
end function

' Converts an HSL color value to RGB. Conversion formula
' adapted from http://en.wikipedia.org/wiki/HSL_color_space.
' Assumes h is contained in the set [0, 360], and s and l
' are contained in the set [0, 100]
' returns r, g, and b in the set [0, 255].
function colors_hsl2rgb(hp as integer, sp as integer, lp as integer) as object
    h = hp / 360
    s = sp / 100
    l = lp / 100

    if s = 0 then
        r = l
        g = l
        b = l
    else
        if l < 0.5 then
            q = l * (1 + s)
        else
            q = l + s - l * s
        end if
        p = 2 * l - q

        r = colors_hue2rgb(p, q, h + 1/3)
        g = colors_hue2rgb(p, q, h)
        b = colors_hue2rgb(p, q, h - 1/3)
    end if

    return {
        r: cint(r * 255),
        g: cint(g * 255),
        b: cint(b * 255)
    }
end function

' Voodoo magic
function colors_hue2rgb(p as dynamic, q as dynamic, t as dynamic) as dynamic
    if t < 0 then
        t += 1
    else if t > 1 then
        t -= 1
    end if

    if t < (1/6) then
        return p + (q - p) * 6 * t
    else if t < (1/2) then
        return q
    else if t < (2/3) then
        return p + (q - p) * (2/3 - t) * 6
    else
        return p
    end if
end function

' Converts an RGB color value to HSL. Conversion formula
' adapted from http://en.wikipedia.org/wiki/HSL_color_space.
' Assumes r, g, and b are contained in the set [0, 255] and
' returns h in the set [0, 360], and s and l in the set [0, 100].
function colors_rgb2hsl(r as dynamic, g as dynamic, b as dynamic) as object
    r = r / 255
    g = g / 255
    b = b / 255

    c_min = min(r, min(g, b))
    c_max = max(r, max(g, b))

    l = (c_max + c_min) / 2

    ' Avoid finite errors
    if abs(c_max - c_min) < 0.00001 then
        return { h: 0, s: 0, l: l }
    else
        delta = c_max - c_min
        s = delta / (1 - abs(2 * l - 1))

        if r = c_max then
            h = (g - b) / delta
            if g < b then
                h = h + 6
            end if
        else if g = c_max then
            h = (b - r) / delta + 2
        else if b = c_max then
            h = (r - g) / delta + 4
        end if

        h = cint(h * 60) ' Convert to degrees
        if h < 0 then h += 360

        s = cint(s * 100 )
        l = cint(l * 100 )
    end if

    return {
        h: h,
        s: s,
        l: l
    }
end function

' given a hex color string, return an object with 0-255 fields
' 'red', 'green', 'blue'
function getDecimalColor(color as string) as object
    hexColor = color.mid(1)
    hexR = hexColor.mid(0, 2)
    hexG = hexColor.mid(2, 2)
    hexB = hexColor.mid(4, 2)
    return {
        red: hex2int(hexR).toStr(),
        green: hex2int(hexG).toStr(),
        blue: hex2int(hexB).toStr()
    }
end function

' Given an RGB color object it returns a Hex color string
function getHexColor(rgbColor as object, fallback = "#FFFFFF") as string
    if rgbColor = invalid or rgbColor.r = invalid or rgbColor.g = invalid or rgbColor.b = invalid then
        return fallback
    end if

    return "#" + int2hex(rgbColor.r) + int2hex(rgbColor.g) + int2hex(rgbColor.b)
end function
