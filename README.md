# DDLogManager [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![Build Status](https://travis-ci.org/HJianBo/DDLogManager.svg?branch=master)](https://travis-ci.org/HJianBo/DDLogManager)
DDLogManager 是一个高效、简单的**日志管理框架**。该项目仅使用 Swift 实现，提供方便的日志输出控制和管理功能。

## 特性
- 支持 iOS/masOS/tvOS/watchOS、Ubuntu
- 分等级的日志打印
- 默认支持 **控制台** **文件** 两种日志输出，也可遵循`DDLoger`协议，增加自定义的日志输出方式
- 可 **自定义打印样式** 遵循 `DDLogerFormatter` 协议

## 要求

- Swift 3.0 +

## 导入
### Swift Package Manager
在 `Packages.swift` 文件中加入依赖
```swift
import PackageDescription

let package = Package(
    name: "YourProjectName",
    dependencies: [
        .Package(url: "https://github.com/HJianBo/DDLogManager", majorVersion: 0)
    ]
)
```

### Carthage
在 `Carthfile` 加入依赖
```
github "HJianBo/DDLogManager" ~> 0.4
```

**Carthage**的使用参见其 [README](https://github.com/Carthage/Carthage)

## 使用
#### 打印日志
在将 **DDLogManager** 加入到工程依赖，并编译成功后，参考如下代码，来打印日志
```swift
import DDLogManager

// Init
DDLogManager.addLoger(DDTTYLoger.sharedInstance) // TTY  = Xcode console
DDLogManager.addLoger(DDFileLoger.sharedInstance) // File = Written log to file

// ...

DDLogVerbose("This is verbose log message.")
DDLogDebug("This is debug log message.")
DDLogInfo("This is info log message.")
DDLogWarn("This is warning log message.")
DDLogError("This is error log message.")
```

#### 设置日志等级
支持给不同的日志打印器，设置特定的日志等级，默认为 `.debug`
```swift
DDTTYLoger.sharedInstance.level = .debug

DDFileLoger.sharedInstance.level = .warning
```

## TODO
1. 支持终端不同日志等级的颜色打印
2. 支持 Linux

## 感谢
参照大神[@CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)完成编写.

Thanks! 😃
