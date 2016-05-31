![GoBus: Elegant way to get data from Inthegra API in Swift.](GoBus.png)

<p align="center">
<a href="https://travis-ci.org/orlandoamorim/GoBus"><img src="https://travis-ci.org/orlandoamorim/GoBus.svg?branch=master" alt="Build status" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift2-compatible-4BC51D.svg?style=flat" alt="Swift 2 compatible" /></a>
<a href="https://cocoapods.org/pods/GoBus"><img src="https://img.shields.io/badge/pod-0.1.1-blue.svg" alt="CocoaPods compatible" /></a>
<a href="https://raw.githubusercontent.com/orlandoamorim/GoBus/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>


## Introduction

**GoBus!** is a library to help developers to interact with Inthegra API in Swift. We provide an easy way to get data and some new features not implemented on api.

## Requirements

* iOS 8.0+
* Xcode 7.3+

## Getting involved

* If you **want to contribute** please feel free to **submit pull requests**.
* If you **have a feature request** please **open an issue**.
* If you **found a bug** check older issues before submitting an issue.

## Example

Follow these 3 steps to run Example project: Clone GoBus repository, open Example workspace and run the *Example* project.

## Usage

### Set Auth Token
It is quite simple to set auth token, just like this:

```swift
import UIKit
import GoBus

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        GoBus().setupWithApiKey(apiKey: String, email: String, password: String, url: String)
        return true
    }
}

```
In this example we just set your application key, email and password. With this, you will automatically logged and the access token retrieved and updated automatically.

Now you are read to use GoBus funcs.

### How to get bus values

We can get bus values by invoking the following three `GoBus` function:

#### Get All Bus

```swift
GoBus().getBus(completion: (([Bus]?, [Line]?, NSError?) -> Void))

GoBus().getBus() { (buss, lines, error) in
    if error != nil {
        print(error?.code)
        print(error?.domain)
    }else {
        if lines != nil {
            for line in lines! {
                print(line.description)
            }
        }

        if buss != nil {
            for bus in buss! {
                print(bus.description)
            }
        }
    }
}

```

Will return an array with Bus objects, an array with Line objects and an NSError

#### All Bus of specific line

```swift
GoBus().getBus(inLine: String?, completion: (([Bus]?, [Line]?, NSError?) -> Void))

GoBus().getBus(inLine: "0408") { (buss, line, error) in
    if error != nil {
        print(error?.code)
        print(error?.domain)
    }else {
        if line != nil {
            //We received only one Line, which correspond to the line researched
            print(line![0].description)
        }

        // - buss - correspond to all Bus in the line researched
        if buss != nil {
            for bus in buss! {
                print(bus.description)
            }
        }
    }
}

```
Pass the number of the line you want to return and will receive an array with Bus objects of this line, an array with the Line and an NSError

#### Use GoBus().getBus PROTOCOL

```swift
//** repeatAfter works in Seconds
GoBus().getBus(inLine: String?, repeatAfter: Double?, completion: (([Bus]?, [Line]?, NSError?) -> Void))

//Usage:

//  1: GoBus().getBus(inLine: "0408", repeatAfter: 30, completion: (([Bus]?, [Line]?, NSError?) -> Void)) with Search
//  2: GoBus().getBus(repeatAfter: 30, completion: (([Bus]?, [Line]?, NSError?) -> Void)) without Search

//  3: In this case, you can use either the first way as the second

// - First, add GoBusDelegate in the class

let go = GoBus()
//Returns both the bus as the line now. From now on, every five seconds the function implemented by the protocol will return updated values.
let cancel = go.getBus(inLine: "0408", repeatAfter: 5) { (buss, line, error) in }

//Using this way (3), now you can cancel repeat After and the call protocol
go.cancel(cancel)
```
### See more like how get Line and Stops in Example Project

## Installation

#### CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

Specify GoBus into your project's `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'GoBus'
```

Then run the following command:

```bash
$ pod install
```
## **To-Do List**
---

- [ ] Add ability to stop being sought by lines 
- [ ] Improve Documentation

## Author

Orlando Amorim, orlandoamorimdev@gmail.com

## License

GoBus is available under the MIT license. See the LICENSE file for more info.
