function init()
  m.top.observeFieldScoped("buttonSelected", "onButtonSelected")
end function

sub onButtonSelected()
  m.top.close = true
end sub
