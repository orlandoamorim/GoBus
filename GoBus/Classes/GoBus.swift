//
//  GoBus.swift
//  GoBus ( https://github.com/orlandoamorim/GoBus )
//
//  Created by Orlando Amorim on 23/05/16.
//  Copyright © 2016 Orlando Amorim. All rights reserved.
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit
import CoreLocation


public class GoBus {
    
    //MARK: Public Variables

    public var delegate:GoBusDelegate?
    
    ///Data from the current user of the Inthegra API
    public var goBusUser: GoBusUser? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let busUser = userDefaults.valueForKey("GoBusUser") as? [String:String] {
                return GoBusUser(dic: busUser)
            }
            return nil
        }
    }
    
    ///The Inthegra API Auth Token
    public var token: String? {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if let goBusAccessToken = userDefaults.valueForKey("GoBusAccessToken") as? [String:AnyObject] {
                return (goBusAccessToken["accessToken"] as! String)
            }
            return nil
        }
    }
    
    //MARK: Init
    public init() { }
    
    /**
     Call this method to authenticate with Inthegra API and get the Auth Token.
     
     ## Important Notes ##
     1. This method will regenerate the Auth Token automatically.
     2. Use this method only in AppDelegate.
     
     - Parameter apiKey: The corresponding access key of your application.
     - Parameter email: Your email.
     - Parameter password: Your password.
     - Parameter url: The url to access the api. -> https://api.inthegra.strans.teresina.pi.gov.br/version
     
     */
    
    public func setupWithApiKey(apiKey:String, email:String, password:String, url:String) {
        let nsurl: NSURL = NSURL(string: "\(url)/signin")!
        let session = NSURLSession.sharedSession()
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)
        
        request.HTTPMethod = "POST"
        let date = NSDate()
        request.allHTTPHeaderFields = ["Content-Type":"application/json", "Accept-Language":"en", "Date":date.dateFormatter().stringFromDate(date) , "X-Api-Key":"\(apiKey)"]
        request.HTTPShouldHandleCookies = false
        
        let params = ["email": email, "password": password] as Dictionary<String, String>
        
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error setting up the Api Key")
            }
            
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                    
                    if (jsonResult["code"] as? Int) != nil {
                        print("code: \(jsonResult["code"] as! Int) | message: \(jsonResult["message"] as! String)")
                        return
                    }
                    
                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    userDefaults.setObject(["accessToken":jsonResult["token"] as! String,"date": date], forKey: "GoBusAccessToken")
                    userDefaults.setObject(["appKey": apiKey, "email": email, "password": password, "url": url], forKey: "GoBusUser")
                    userDefaults.synchronize()
                    
                    //After 9 min recal the func to get new token
                    self.repeatAfter(540, closure: {
                        self.setupWithApiKey(apiKey, email: email, password: password, url: url)
                    })
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
    
    /**
     Private method to get data from the Inthegra API.
    
     - Parameter type: The requisition type.
     - Parameter search: Research by user.
     - Parameter completion:  A closure which is called with NSData?(correspond to the data returned by api), NSURLResponse?  and NSError?(if the api returned error)

     */
    
    private func get(type:GoBusGetTypes, search: String?=nil, completionHandler: (NSData?, NSURLResponse?, NSError?) -> Void){
        
        ///If the access token has not yet been generated, wait 2 seconds
        repeat {
            sleep(0)
        }while (goBusUser == nil || goBusUser?.appKey == nil || goBusUser?.url == nil )
        
        let nsurl: NSURL = search != nil ? NSURL(string: "\(goBusUser!.url)/\(type.rawValue)\(search!)")! : NSURL(string: "\(goBusUser!.url)/\(type.rawValue)")!
        let session = NSURLSession.sharedSession()
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: nsurl)

        request.HTTPMethod = "GET"
        let date = NSDate()
        request.allHTTPHeaderFields = ["Content-Type":"application/json", "Accept-Language":"en", "Date": date.dateFormatter().stringFromDate(date), "X-Api-Key":"\(goBusUser!.appKey)", "X-Auth-Token": self.token!]
        request.HTTPShouldHandleCookies = false

        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            completionHandler(data, response, error)
        })
        
        task.resume()
    }
    
    /**
     Sends an API request to Inthegra for stops with an optional text search
     
     - Parameter search: An optional search query
     - Parameter completion:  A closure which is called with an array of Stop objects and an NSError
     
     */
    
    public func getStops(search search: String?=nil, completion: (([Stop]?, NSError?) -> Void)){
        backgroundThread(background: {
            self.get(search != nil ? GoBusGetTypes.ParadasBusca : GoBusGetTypes.Paradas) { (data, response, error) in
                if error != nil {
                    completion(nil, error)
                    return
                }
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                        var stops:[Stop] = [Stop]()
                        for stop in jsonResult {
                            stops.append(Stop(dic: (stop as! NSDictionary) as! [String:AnyObject]))
                        }
                        completion(stops, nil)
                    }
                } catch let error as NSError {
                    completion(nil, error)
                    print(error.localizedDescription)
                }
            }
        }, completion: nil)
    }
    
    /**
     Sends an API request to Inthegra for stops around a given location with an optional radius
     
     - Parameter latitude: The latitude you want search
     - Parameter longitude: The longitude you want search
     - Parameter radius: An optional radius to set the maximum area to return Stop objects
     - Parameter completion:  A closure which is called with the nearest Stop, an array of Stop objects and an NSError
     
     */
    
    public func getStopsNearest(latitude latitude: Double, longitude: Double, radius: Int?=nil, completion: ((Stop?,[Stop]?, NSError?) -> Void)){
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        getStops { (stops, error) in
            if error != nil {
                completion(nil, nil, error)
                return
            }
            var stopsSort:[Stop] = [Stop]()
            if stops != nil {
                stopsSort = stops!.sort({ $0.distanceFrom(location) < $1.distanceFrom(location) })
            }
            for stop in stopsSort {
                if stop.coordinate.isZero() {
                    stopsSort.remove(stop)
                }else if radius != nil {
                    if let distance = stop.distanceFrom(location) {
                        if Int(round(Double(distance))) > radius! {
                            stopsSort.remove(stop)
                        }
                    }else {
                        stopsSort.remove(stop)
                    }
                }
            }
            
            completion(stopsSort.first, stopsSort, error)
        }
        
    }
    
    /**
     Sends an API request to Inthegra for lines with an optional text search
     
     - Parameter search: An optional search query
     - Parameter completion:  A closure which is called with an array of Line objects and an NSError
     
     */
    
    public func getLines(search search: String?=nil, completion: (([Line]?, NSError?) -> Void)){
        backgroundThread(background: {
            self.get(search != nil ? GoBusGetTypes.BuscaLinha : GoBusGetTypes.Linhas, search: search) { (data, response, error) in
                
                if error != nil {
                    completion(nil, error)
                    return
                }
                
                do {
                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                        let result = jsonResult as! [[String: AnyObject]]
                        
                        var lines:[Line] = [Line]()
                        for line in result {
                            lines.append(Line(dic: line))
                        }
                        completion(lines, nil)
                    }
                } catch let error as NSError {
                    completion(nil, error)
                    print(error.localizedDescription)
                }
            }
        }, completion: nil)
    }
    
    /**
     Sends an API request to Inthegra for stops around a given location with an optional radius
     
     - Parameter inLine: An optional search query
     - Parameter repeatAfter: An optional way to set time in seconds to continuously call this function and returns the results in GoBusDelegate
     - Parameter completion:  A closure which is called with an array of Bus objects, an array of Line objects and an NSError
     
     - Returns: An *cancelClosure* to be used to cancel *repeatAfter* GoBusDelegate call
     
     - SeeAlso:  `cancel(_:)` if you will use *GoBusDelegate* and *repeatAfter*
     
     */
    
    public func getBus(inLine inLine: String?=nil, repeatAfter: Double?=nil, completion: (([Bus]?, [Line]?, NSError?) -> Void)) -> cancelClosure?{
        
        backgroundThread(background: {
            self.get(inLine != nil ? GoBusGetTypes.VeiculosLinhaBusca : GoBusGetTypes.Veiculos, search: inLine) { (data, response, error) in
                
                if error != nil {
                    completion(nil, nil, error)
                    return
                }
                
                if inLine != nil {
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                            if (jsonResult["code"] as? Int) != nil {
                                completion(nil, nil, NSError(domain: jsonResult["message"] as! String, code: jsonResult["code"] as! Int, userInfo: nil))
                                return
                            }
                            
                            let result = (jsonResult as! [String: [String:AnyObject]])["Linha"]
                            
                            var lines:[Line] = [Line]()
                            lines.append(Line(dic: result!))
                            
                            var buss:[Bus] = [Bus]()
                            for line in lines {
                                if line.bus != nil {
                                    for bus in line.bus! {
                                        buss.append(bus)
                                    }
                                }
                            }
                            
                            completion(buss,lines,error)
                        }
                    } catch let error as NSError {
                        completion(nil, nil, error)
                        print(error.localizedDescription)
                    }
                }else {
                    do {
                        if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSArray {
                            let result = jsonResult as! [[String: [String:AnyObject]]]
                            
                            var lines:[Line] = [Line]()
                            for line in result {
                                lines.append(Line(dic: line["Linha"]!))
                            }
                            
                            var buss:[Bus] = [Bus]()
                            for line in lines {
                                if line.bus != nil {
                                    for bus in line.bus! {
                                        buss.append(bus)
                                    }
                                }
                            }
                            
                            completion(buss, lines, nil)
                        }
                    } catch let error as NSError {
                        completion(nil, nil, error)
                        print(error.localizedDescription)
                    }
                }
            }
            
            
            }, completion: nil)
        
        if repeatAfter != nil {
            return self.repeatAfter(repeatAfter!) {
                self.getBus(inLine: inLine, repeatAfter: repeatAfter, completion: { (bus, lines, error) in
                    self.delegate!.getBus(bus, lines: lines, error: error)
                })
            }
        }
        
        return nil
    }
    
    /**
     Sends an API request to Inthegra for bus around a given location with an optional search and radius
     
     - Parameter latitude: The latitude you want search
     - Parameter longitude: The longitude you want search
     - Parameter search: An optional search query for Line
     - Parameter radius: An optional radius to set the maximum area to return Stop objects
     - Parameter completion:  A closure which is called with the nearest Bus, an array of Bus objects and an NSError
     
     */
    
    public func getBusNearest(latitude latitude: Double, longitude: Double,inLine: String?=nil, radius: Int?=nil, completion: ((Bus?,[Bus]?, NSError?) -> Void)){
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        getBus(inLine: inLine) { (buss, lines, error) in
            if error != nil {
                completion(nil, nil, error)
                return
            }
            var busSort:[Bus] = [Bus]()
            
            if buss != nil {
                busSort = buss!.sort({ $0.distanceFrom(location) < $1.distanceFrom(location) })
            }
            
            for bus in busSort {
                if bus.coordinate.isZero() {
                    busSort.remove(bus)
                }else if radius != nil {
                    if let distance = bus.distanceFrom(location) {
                        print(distance)
                        if Int(round(Double(distance))) > radius! {
                            busSort.remove(bus)
                        }
                    }else{
                        busSort.remove(bus)
                    }
                }
            }
            
            completion(busSort.first, busSort, error)
        }
        
    }
    
    /**
     Use this to cancel an repeatAfter call in protocol
     
     - Parameter closure: The `cancelClosure` returned by `getBus(_:)` function.
    
     - SeeAlso: `getBus(_:)` to use this method
     
     */
    public func cancel(closure:cancelClosure?) {
        
        if closure != nil {
            closure!(cancel: true)
        }
    }
    
    
//******************************************* Core
    
    //http://stackoverflow.com/a/25120393/4642682
    //*
    public typealias cancelClosure = (cancel : Bool) -> Void
    
    private func repeatAfter(time:NSTimeInterval, closure:()->Void) ->  cancelClosure? {
        
        func dispatch_later(clsr:()->Void) {
            dispatch_after(
                dispatch_time(
                    DISPATCH_TIME_NOW,
                    Int64(time * Double(NSEC_PER_SEC))
                ),
                dispatch_get_main_queue(), clsr)
        }
        
        var closure:dispatch_block_t? = closure
        var cancelableClosure:cancelClosure?
        
        let delayedClosure:cancelClosure = { cancel in
            if closure != nil {
                if (cancel == false) {
                    dispatch_async(dispatch_get_main_queue(), closure!);
                }
            }
            closure = nil
            cancelableClosure = nil
        }
        
        cancelableClosure = delayedClosure
        
        dispatch_later {
            if let delayedClosure = cancelableClosure {
                delayedClosure(cancel: false)
            }
        }
        
        return cancelableClosure
    }
    //*
    
    ///http://stackoverflow.com/a/30841417/4642682
    private func backgroundThread(delay: Double = 0.0, background: (() -> Void)? = nil, completion: (() -> Void)? = nil) {
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)) {
            if(background != nil){ background!(); }
            
            let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
            dispatch_after(popTime, dispatch_get_main_queue()) {
                if(completion != nil){ completion!(); }
            }
        }
    }
}