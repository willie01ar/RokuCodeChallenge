sub runUserInterface(args as object)
    printBootArgs(args)

    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    scene = screen.CreateScene("MainScene")
    screen.show()

    while(true)
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then 
              return
            end if 
        end if
    end while
end sub

sub printBootArgs(args)
  ?"== boot arguments =="
  ?formatJSON(args)
end sub

