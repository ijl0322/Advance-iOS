//
//  WCSessionManager.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 10/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import WatchConnectivity

class WCSessionManager: NSObject, WCSessionDelegate {
    
    static let sharedInstance = WCSessionManager()
    fileprivate override init() {
        super.init()
    }
    
    fileprivate let session: WCSession? = WCSession.isSupported() ? WCSession.default() : nil
    
    fileprivate var validSession: WCSession? {
        if let session = session, session.isPaired && session.isWatchAppInstalled {
            return session
        }
        return nil
    }
    
    //Start the WCSession
    func startSession() {
        session?.delegate = self
        session?.activate()
    }
}

extension WCSessionManager {

    //Sends the applicationContext to the watch
    func updateApplicationContext(_ applicationContext: [String : AnyObject]) throws {
        if let session = validSession {
            do {
                print("sending message to watch")
                try session.updateApplicationContext(applicationContext)
            } catch let error {
                throw error
            }
        }
    }
    
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
    }
    
    
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    @available(iOS 9.3, *)
    public func session(_ session: WCSession,
                        activationDidCompleteWith activationState: WCSessionActivationState,
                        error: Error?) {
        print("Actication: \(activationState)")
    }
    
    func session(_ session: WCSession,
                 didReceiveApplicationContext applicationContext: [String : Any]) {
        print("Message Data:\(String(describing: applicationContext["goodbye"]))")
        DispatchQueue.main.async {
            let userDefault = UserDefaults.standard
            userDefault.setValue("hi from watch", forKey: "messageFromWatch")
        }
    }
    
    //Receive data from watch
    //The watch sends over a FavoriteLocation object that is archieved to Data
    //Unarchieve the object and update cloudkit's record accordingly
    func session(_ session: WCSession,
                 didReceiveMessage message: [String : Any],
                 replyHandler: @escaping ([String : Any]) -> Void) {
        
        let places = message["hello"] as? Data
        let actualObject = NSKeyedUnarchiver.unarchiveObject(with: places!) as! FavoriteLocation
        print("Message Data:\(String(describing: actualObject.comment))")
        print("Message Data:\(String(describing: actualObject.likes))")
        DispatchQueue.main.async {
            ClouldKitManager.sharedInstance.update(records: [actualObject.record])
        }
    }
}
