'Centralized logging. Because excessive print statements can
'slow down an application, it's useful to break them up into
'four categories:

'   ConsoleLogLog().error() : Something is wrong and we can't continue
'   ConsoleLogLog().warn() : Something may be wrong, but we might be able to continue
'   ConsoleLogLog().info() : Something happened that we want to comment about it
'   ConsoleLogLog().debug() : Something for developers to talk around with

'The componentId can be overridden in case you want to refer
'to and included filename. Otherwise it defaults to the
'component subtype

function ConsoleLog()
    if m.log = invalid then
        m.log = {
            error: _log_error
            warn:  _log_warn
            info:  _log_info
            debug: _log_debug
        }
    end if
    return m.log
end function

sub _log_error(msg as dynamic, componentId = "none" as string)
    _log_printLogMessage("ERROR", msg, componentId)
end sub

sub _log_warn(msg as dynamic, componentId = "none" as string)
    _log_printLogMessage("WARNING", msg, componentId)
end sub

sub _log_info(msg as dynamic, componentId = "none" as string)
    ' Roku does not support 'and/or' boolean logic operators 
    ' in conditional compilation conditions. ¯\_(ツ)_/¯
    #if IS_AUTOMATION_BUILD
        _log_printLogMessage("INFO", msg, componentId)
    #else if ENABLE_DBG
        _log_printLogMessage("INFO", msg, componentId)
    #end if
end sub

sub _log_debug(msg as dynamic, componentId = "none" as string)
    ' Roku does not support 'and/or' boolean logic operators 
    ' in conditional compilation conditions. ¯\_(ツ)_/¯
    #if IS_AUTOMATION_BUILD
        _log_printLogMessage("DEBUG", msg, componentId)
    #else if ENABLE_DBG
        _log_printLogMessage("DEBUG", msg, componentId)
    #end if
end sub

sub _log_printLogMessage(logLevel as String, msg as Dynamic, componentId = "none" as String)
    if componentId = "none" and m.top <> invalid then
        componentId = m.top.subType()
    end if

    enhance = logEnhance(logLevel)
    print enhance.prefix;
    print logLevel; "  "; componentId; ": "; msg;
    print enhance.suffix
end sub

function logEnhance(logLevel as string) as object
    prefix = ""
    suffix = ""
#if ENABLE_DBG
    ' For ANSI color details, see:
    ' https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit
    foregrounds = {
        DEBUG: "85;85;85",   ' #555555
        ERROR: "204;0;0",    ' #CC0000
        INFO: "0;85;153",    ' #005599
        WARNING: "255;153;0" ' #FF9900
    }
    foreground = foregrounds[logLevel]
    if foreground <> invalid then
        csi = chr(&h1B) + "[" ' control sequence introducer
        prefix = csi + "38;2;" + foreground + "m"
        suffix = csi + "0m" ' reset
    end if
#end if
    return { prefix: prefix, suffix: suffix }
end function
