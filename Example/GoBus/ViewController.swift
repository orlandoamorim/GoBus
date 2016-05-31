//
//  ViewController.swift
//  GoBus
//
//  Created by Orlando Amorim on 23/05/2016.
//  Copyright (c) 2016 Orlando Amorim. All rights reserved.
//

import UIKit
import GoBus

class ViewController: UIViewController, GoBusDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ********************************* All .getBus() options
        
        //GoBus().getBus(inLine: String?, repeatAfter: Double?, completion: (([Bus]?, [Line]?, NSError?) -> Void))

        // --***** All vehicle and lines
        
        //GoBus().getBus(completion: (([Bus]?, [Line]?, NSError?) -> Void))
        
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
        
        // --***** All vehicle of specific line
        
        //GoBus().getBus(inLine: String?, completion: (([Bus]?, [Line]?, NSError?) -> Void))
        
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
        
        // --***** Use GoBus().getBus PROTOCOL
        
        //** repeatAfter works in Seconds
        
        //GoBus().getBus(inLine: String?, repeatAfter: Double?, completion: (([Bus]?, [Line]?, NSError?) -> Void))
        
        //Usage:
        
        //  1: GoBus().getBus(inLine: "0408", repeatAfter: 30, completion: (([Bus]?, [Line]?, NSError?) -> Void)) with Search
        //  2: GoBus().getBus(repeatAfter: 30, completion: (([Bus]?, [Line]?, NSError?) -> Void)) without Search
        
        //  3: In this case, you can use either the first way as the second
        
        
        let go = GoBus()
        //Returns both the bus as the line now. From now on, every five seconds the function implemented by the protocol will return updated values.
        let cancel = go.getBus(inLine: "0408", repeatAfter: 5) { (buss, line, error) in }
        
        //Using this way (3), now you can cancel repeat After and the call protocol
        go.cancel(cancel)
    
        //---------------------------------------------------------------------------------------------------
        
        // ********************************* All .getLines() options
        
        //GoBus().getLines(search: String?, completion: (([Line]?, NSError?) -> Void))
        
        // --***** Return all lines
        GoBus().getLines { (lines, error) in
            if error != nil {
                print(error?.code)
                print(error?.domain)
            }else {
                for line in lines! {
                    print("**************")
                    print(line.description)
                    print("**************")
                }
            }
        }
        
        // --***** Return only the specified line. 
        // -- Search works with line name, the point of origin or point of return
        GoBus().getLines(search: "ininga") { (line, error) in
            if error != nil {
                print(error?.code)
                print(error?.domain)
            }else {
                print(line?[0].description)
            }
        }
        
        //---------------------------------------------------------------------------------------------------

        // ********************************* All .getStops() options

        //GoBus().getStops(search: String?, completion: (([Stop]?, NSError?) -> Void))
        
        // --***** Return all stops
        GoBus().getStops { (stops, error) in
            if error != nil {
                print(error?.code)
                print(error?.domain)
            }else {
                for stop in stops! {
                    print("**************")
                    print(stop.description)
                    print("**************")
                }
            }
        }
        
        // --***** Return only the specified Stop.
        // -- Search works with line name or address
        GoBus().getStops(search: "ininga") { (stops, error) in
            if error != nil {
                print(error?.code)
                print(error?.domain)
            }else {
                for stop in stops! {
                    print("**************")
                    print(stop.description)
                    print("**************")
                }
            }
        }
        
        // ********************************* Working with nearest

        // --***** Return all bus nearest
        
            // -- ** 1 
        
            // radius - distance in meters
        
            GoBus().getBusNearest(latitude: -5.056221603326806, longitude: -42.79030821362158, inLine: "0408", radius: 1400) { (bus, buss, error) in
                if error != nil {
                    print(error?.code)
                    print(error?.domain)
                }else {
                    // - bus: The most nearest bus
                    // - buss: All nearest bus. obs: If is not null radius, so the bus returns within that radius. Same for inLine.
                    print(bus?.description)
                    
                    if buss != nil {
                        for bus in buss! {
                            print("**************")
                            print(bus.description)
                            print("**************")
                        }
                    }
                }
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Func used in getBus func with repeatAfter
    func getBus(bus: [Bus]?, lines: [Line]?, error: NSError?) {
        if error != nil {
            print(error?.code)
            print(error?.domain)
        }else {
            if lines != nil {
                for line in lines! {
                    print(line.description)
                }
            }
            
            if bus != nil {
                for bus in bus! {
                    print(bus.description)
                }
            }
        }
    }
    

}

