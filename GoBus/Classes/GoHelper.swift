//
//  GoHelper.swift
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
import CoreLocation
import MapKit

// MARK: - GoBusUser
//********************************** GoBusUser ***************************************//

public class GoBusUser: CustomStringConvertible {
    
    /// The app key string
    public let appKey: String
    
    /// The user email string
    public let email: String
    
    /// The user password string
    public let password: String
    
    /// The access url string
    public let url: String
    
    
    public init(appKey:String, email:String, password:String, url:String) {
        self.appKey = appKey
        self.email = email
        self.password = password
        self.url = url
    }
    
    public convenience init(dic:[String:String]){
        self.init(appKey: dic["appKey"]!, email: dic["email"]!, password: dic["password"]!, url: dic["url"]!)
    }
    
    
    public var description : String {
        return "App Key: \(self.appKey) | Email: \(self.email) | Password: \(self.password) | Url: \(self.url)"
    }
    
}

// MARK: - Bus
//************************************** Bus ****************************************//

public class Bus: NSObject, MKAnnotation {
    
    /// The bus code string
    public let code: String
    
    /// The bus latitude string
    public let lat: Double
    
    /// The bus longitute string
    public let long: Double
    
    /// The bus requisition time string
    public let time: String
    
    /**
     Use this method to get the location in `CLLocationCoordinate2D`
     
     - Warning: Verify if latitude and longitude are 0.0
     
     */
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    public init(code: String, lat: Double, long:Double, time:String) {
        self.code = code
        self.lat = lat
        self.long = long
        self.time = time
    }
    
    public convenience init(dic:[String:AnyObject]){
        self.init(code: dic["CodigoVeiculo"] as! String, lat: Double(dic["Lat"] as? String != nil  ? dic["Lat"] as! String : "0.0")! , long: Double(dic["Long"] as? String != nil  ? dic["Long"] as! String : "0.0")! , time: dic["Hora"] as! String )
    }
    
    override public var description : String {
        return "Code: \(self.code) | Lat: \(self.lat) | Long: \(self.long) | Time: \(self.time)"
    }
    
    /**
     Use this method to get the distance from another location.
     
     - Parameter location: The location you want to compare.
     - Returns: An *CLLocationDistance* .
     
     - Warning: If latitude and longitude are 0.0 will return `nil`.
     
     */
    
    public func distanceFrom(location: CLLocationCoordinate2D) -> CLLocationDistance? {
        if self.lat != 0.0 && long != 0.0 {
            return CLLocationCoordinate2D(latitude: lat, longitude: long).distanceInMetersFrom(location)
        }
        return nil
    }
}

// MARK: - Stop
//************************************** Stop ***************************************//

public class Stop: NSObject, MKAnnotation  {
    
    /// The bus stop code string
    public let code: String
    
    /// The bus stop name string
    public let name: String
    
    /// The bus stop address string
    public let address: String
    
    /// The bus stop latitude string
    public let lat: Double
    
    /// The bus stop longitude string
    public let long: Double
    
    /**
     Use this method to get the location in `CLLocationCoordinate2D`
     
     - Warning: Verify if latitude and longitude are 0.0
     
     */
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    public init(code: String, name: String, address: String, lat: Double, long: Double) {
        self.code = code
        self.name = name
        self.address = address
        self.lat = lat
        self.long = long
    }
    
    public convenience init(dic:[String:AnyObject]){
        self.init(code: String(dic["CodigoParada"] as! Int), name: dic["Denomicao"] as! String, address: dic["Endereco"] as? String != nil ? dic["Endereco"] as! String : "", lat: Double(dic["Lat"] as? String != nil  ? dic["Lat"] as! String : "0.0")! , long: Double(dic["Long"] as? String != nil  ? dic["Long"] as! String : "0.0")! )
    }
    
    override public var description : String {
        return "Code: \(self.code) | Name: \(self.name) | Address: \(self.address) | Lat: \(self.lat) | Long: \(self.long)"
    }
    
    /**
     Use this method to get the distance from another location.
     
     - Parameter location: The location you want to compare.
     - Returns: An *CLLocationDistance* .
     
     - Warning: If latitude and longitude are 0.0 will return `nil`.
     
     */
    
    public func distanceFrom(location: CLLocationCoordinate2D) -> CLLocationDistance? {
        if self.lat != 0.0 && long != 0.0 {
            return CLLocationCoordinate2D(latitude: lat, longitude: long).distanceInMetersFrom(location)
        }
        return nil
    }
    
}

// MARK: - Line
//************************************** Line ***************************************//

public class Line : CustomStringConvertible {
    
    /// The line circular string
    public let circular: String
    
    /// The line code string
    public let code: String
    
    /// The line name string
    public let name: String
    
    /// The line origin string
    public let origin: String
    
    /// The line destiny string
    public let destiny: String
    
    /// The line bus array
    public var bus:[Bus]?
    
    /// The line stops array
    public var stop:[Stop]?
    
    public init(circular:String, code: String, name:String, origin: String, destiny: String, bus:[[String:AnyObject]]?, stops:[[String:AnyObject]]?) {
        self.circular = circular
        self.code = code
        self.name = name
        self.origin = origin
        self.destiny = destiny
        
        if bus != nil {
            self.bus = [Bus]()
            self.bus?.removeAll()
            for b in bus! {
                self.bus?.append(Bus(dic: b))
            }
        }
        
        if stops != nil {
            self.stop = [Stop]()
            self.stop?.removeAll()
            for s in stops! {
                self.stop?.append(Stop(dic: s))
            }
        }
    }
    
    public convenience init(dic:[String:AnyObject]){
        self.init(circular: "\(dic["Circular"] as! Bool)", code: dic["CodigoLinha"] as! String, name: dic["Denomicao"] as! String, origin: dic["Origem"] as? String != nil ? dic["Origem"] as! String : "", destiny: dic["Retorno"] as? String != nil ? dic["Retorno"] as! String : "", bus: dic["Veiculos"] as? [[String:AnyObject]],stops: nil )
    }
    
    public convenience init(line:[String:AnyObject], stops:[[String:AnyObject]]){
        self.init(circular: "\(line["Circular"] as! Bool)", code: line["CodigoLinha"] as! String, name: line["Denomicao"] as! String, origin: line["Origem"] as! String, destiny: line["Retorno"] as! String,bus: nil, stops: stops)
    }
    
    public var description : String {
        return "Circular: \(self.circular) | Code: \(self.code) | Name: \(self.name) | Origin: \(self.origin) | Destiny: \(self.destiny) | Bus Count: \(self.bus?.count) | Stops Count: \(self.stop?.count)"
    }
}

//***********************************************************************************//

