
import DDLogManager


DDLogManager.addLoger(DDTTYLoger.sharedInstance) // TTY  = Xcode console
DDLogManager.addLoger(DDFileLoger()) // File = Written log to file

// ...

DDLogVerbose("This is verbose log message.")
DDLogDebug("This is debug log message.")
DDLogInfo("This is info log message.")
DDLogWarn("This is warning log message.")
DDLogError("This is error log message.")
