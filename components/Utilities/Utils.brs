function url_encode(str as String) as String
  uri = CreateObject("roUrlTransfer")
  return uri.Escape(str)
end function

function replaceAll(str as String, find as String, replaceWith as String) as String
  result = str
  while result.Instr(find) >= 0
    result = result.Replace(find, replaceWith)
  end while
  return result
end function

function getNodePosition(node as Object) as Object
  position = [0, 0]

  while node <> invalid
    nodeTranslation = node.translation
    position[0] = position[0] + nodeTranslation[0]
    position[1] = position[1] + nodeTranslation[1]
    node = node.getParent()
  end while

  return position
end function

function int2hex(i as integer, digits = 2 as integer, leftPadStr = "0" as string) as string
  hex = strI(i, 16)
  pad = digits - hex.len()
  if pad > 0 then hex = string(pad, leftPadStr) + hex
  return hex
end function

function hex2int(hex as string) as integer
  return val(hex, 16)
end function

function implements(x as dynamic, interfaceName as string) as boolean
  return x <> invalid and getInterface(x, interfaceName) <> invalid
end function

' Returns true if `x` is not a non-whitespace string.
function isBlank(x as dynamic) as boolean
  return not implements(x, "ifString") or x.trim() = ""
end function

function isPureArray(x as dynamic) as boolean
  return not implements(x, "ifAssociativeArray") and implements(x, "ifArray")
end function