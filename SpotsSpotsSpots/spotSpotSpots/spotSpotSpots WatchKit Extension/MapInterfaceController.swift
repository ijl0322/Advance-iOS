//
//  MapInterfaceController.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//


import WatchKit
import MapKit
import Foundation
import CoreLocation
import CloudKit
import WatchConnectivity

class MapInterfaceController: WKInterfaceController {
    
    @IBOutlet var map: WKInterfaceMap!
    @IBOutlet var commentLabel: WKInterfaceLabel!
    var locationComment: String?
    var locationObject: FavoriteLocation?
    
    @IBAction func locationLiked() {
        print("Like")
        locationObject?.likes += 1
        locationObject?.record["Likes"] = locationObject?.likes as CKRecordValue?
        WCSessionManager.sharedInstance.sendLocationForUpdate(locationObject: locationObject!)
    }

    @IBAction func locationDisliked() {
        print("Dislike")
        locationObject?.dislikes += 1
        locationObject?.record["Dislikes"] = locationObject?.dislikes as CKRecordValue?
        WCSessionManager.sharedInstance.sendLocationForUpdate(locationObject: locationObject!)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        locationObject = context as? FavoriteLocation
        commentLabel.setText(locationObject?.comment)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let location = locationObject?.location?.coordinate
        let region = MKCoordinateRegionMake(location!, span)
        map.setRegion(region)
        map.addAnnotation(location!, with: .red)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
