# DDLogManager
DDLogManager 是一个简单的、纯Swift实现的**日志管理框架**。提供方便的日志输出控制和管理功能。

# 特性
分等级的日志打印控制框架

- 支持 **控制台** **文件** 的 Log 输出
- 可 **自定义打印样式** 遵循 `DDLogerFormatter` 协议

# 要求

- Mac OS 10.10 +
- iOS 8.0 +
- Swift 2.1 +

# 使用

``` Swift

import DDLogManager

```

``` Swift
// Init

DDLogManager.addLoger(DDTTYLoger.sharedInstance) // TTY  = Xcode console
DDLogManager.addLoger(DDFileLoger()) // File = Written log to file

// ...

DDLogVerbose("This is verbose log message.")
DDLogDebug("This is debug log message.")
DDLogInfo("This is info log message.")
DDLogWarn("This is warning log message.")
DDLogError("This is error log message.")

```

# 感谢
参照大神[@CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)编写.

Thanks! 😃
