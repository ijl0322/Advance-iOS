//
//  NotificationController.swift
//  spotSpotSpots WatchKit Extension
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet var locationCommentLabel: WKInterfaceLabel!
    
    @IBOutlet var locationImageVIew: WKInterfaceImage!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }


    override func didReceive(_ notification: UNNotification, withCompletion completionHandler: @escaping (WKUserNotificationInterfaceType) -> Swift.Void) {
        print("Received notification: \(notification.request.content.body)")
        dump(notification.request.content.userInfo)
        if let location = notification.request.content.userInfo["newLocation"] {
            let locationObject = NSKeyedUnarchiver.unarchiveObject(with: location as! Data) as! FavoriteLocation
            if let image = locationObject.photo {
                locationImageVIew.setImage(image)
            }
        }
        locationCommentLabel.setText(notification.request.content.body)
        completionHandler(.custom)
    }

}
