//
//  DataTypes.swift
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
import UIKit

///Used in GoBus.getBus(_:) to continuously update the request
public protocol GoBusDelegate {
    func getBus(bus:[Bus]?, lines: [Line]?,error: NSError?)
}

/**
    Inthegra API request options.
 
 ````
    case Linhas
    case BuscaLinha
    case Paradas
    case ParadasBusca
    case ParadasLinhaBusca
    case Veiculos
    case VeiculosLinhaBusca
 ````
 */

public enum GoBusGetTypes:String {
    case Linhas = "linhas"
    case BuscaLinha = "linhas?busca="
    case Paradas = "paradas"
    case ParadasBusca = "paradas?busca="
    case ParadasLinhaBusca = "paradasLinha?busca="
    case Veiculos = "veiculos"
    case VeiculosLinhaBusca = "veiculosLinha?busca="
}

extension NSDate {
    
    func dateFormatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle =  NSDateFormatterStyle.FullStyle
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss 'GMT'"
        return dateFormatter
    }
    
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
}

extension CLLocationCoordinate2D {
    func distanceInMetersFrom(otherCoord : CLLocationCoordinate2D) -> CLLocationDistance {
        let firstLoc = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
    }
    
    ///If the CLLocationCoordinate2D has latitude and longitude equals to 0.0 returns true
    func isZero() -> Bool {
        if self.longitude == 0.0 && self.latitude == 0.0 {
            return true
        }
        
        return false
    }
}

//http://stackoverflow.com/a/34537466/4642682
extension Array where Element: AnyObject {
    mutating func remove(object: Element) {
        if let index = indexOf({ $0 === object }) {
            removeAtIndex(index)
        }
    }
}
