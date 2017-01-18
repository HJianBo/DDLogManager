
import DDLogManager
import Dispatch


DDFileLoger.sharedInstance.folderName = "name"

DDLogManager.addLoger(DDTTYLoger.sharedInstance) // TTY  = Xcode console
DDLogManager.addLoger(DDFileLoger.sharedInstance) // File = Written log to file

// set log level
DDTTYLoger.sharedInstance.level = .debug


DDLogVerbose("This is verbose log message.")
DDLogDebug("This is debug log message.")
DDLogInfo("This is info log message.")
DDLogWarn("This is warning log message.")
DDLogError("This is error log message.")

DDLogWarn(["key": 123])

// loop for test async
for i in 0..<1000 {
    DDLogWarn("[\(i)]")
}

DDLogWarn("-----------")

for i in 0..<100 {
    DispatchQueue.global().async {
        DDLogWarn("\(i)")
    }
}

//
dispatchMain()
