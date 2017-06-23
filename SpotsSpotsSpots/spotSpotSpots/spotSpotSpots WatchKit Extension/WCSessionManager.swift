//
//  WCSessionManager.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 10/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//


import WatchConnectivity

class WCSessionManager: NSObject, WCSessionDelegate{
    static let sharedInstance = WCSessionManager()
    fileprivate override init() {
        super.init()
        
    }
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
    
    //Archieve a FavoriteLocation object and send over to the iphone to update the data
    //in cloudkit
    func sendLocationForUpdate(locationObject: FavoriteLocation) {
        let data = NSKeyedArchiver.archivedData(withRootObject: locationObject as Any)
        let applicationDictMessage = ["hello": data]
        session?.sendMessage(applicationDictMessage, replyHandler: { (reply) in
            print("Reply: \(reply)")
        }) { (error) in
            print("Error: \(error)")
        }
    }
    
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        print("WCSession activated")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        let places = applicationContext["hello"] as? Data
        let actualObject = NSKeyedUnarchiver.unarchiveObject(with: places!) as! [FavoriteLocation]
        print("We received the following places")
        for place in actualObject{
            print("\(place.comment ?? "No comment")")
        }
        
        //Saving to user defaults
        let defaults = UserDefaults.standard
        defaults.setValue(places, forKey: "places")
    }
}
