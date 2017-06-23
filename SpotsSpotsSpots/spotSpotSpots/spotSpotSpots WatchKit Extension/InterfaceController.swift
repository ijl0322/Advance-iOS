//
//  InterfaceController.swift
//  spotSpotSpots WatchKit Extension
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.

//  MARK: - Attribution
//  https://www.natashatherobot.com/watchkit-actionable-notifications/
//  https://makeapppie.com/2016/12/05/add-actions-and-categories-to-notification-in-swift/
//  https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/SubscribingtoRecordChanges/SubscribingtoRecordChanges.html


import WatchKit
import Foundation
import UserNotifications
import CloudKit

class InterfaceController: WKInterfaceController, UNUserNotificationCenterDelegate {

    var places: [FavoriteLocation] = []
    
    @IBOutlet var locationInterfaceTable: WKInterfaceTable!
    @IBOutlet var noSpotsLabel: WKInterfaceLabel!
    @IBOutlet var sendNotificationButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        WCSessionManager.sharedInstance.startSession()
    }
    
    //Manually add a notification to test the dynamic notification
    @IBAction func sendData() {
        print("Adding notification")
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let locationData = NSKeyedArchiver.archivedData(withRootObject: places[0])
        
        let content = UNMutableNotificationContent()
        content.title = "New Spot Alert!"
        content.body = "A new spot was added!"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "myCategory"
        if let comment = places[0].comment {
            content.body = "\(comment) was added!"
        }
        content.sound = UNNotificationSound.default()
        content.userInfo = ["newLocation": locationData]
        
        let likeAction = UNNotificationAction(identifier: "like", title: "Like", options: [])
        let dislikeAction = UNNotificationAction(identifier: "dislike", title: "Dislike", options: [])
        let category = UNNotificationCategory(identifier: "myCategory",
                                              actions: [likeAction, dislikeAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        center.setNotificationCategories([category])
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: TimeInterval(10),
                                                             repeats: false)
        let id = String(Date().timeIntervalSinceReferenceDate)
        let request = UNNotificationRequest.init(identifier: id, content: content, trigger: trigger)
        center.add(request)
    }
    
    override func willActivate() {
        super.willActivate()
        
        //Fetching the update we received from iPhone
        if let data = UserDefaults.standard.object(forKey: "places") as? Data {
            let actualObject = NSKeyedUnarchiver.unarchiveObject(with: data) as! [FavoriteLocation]
            places = actualObject
            print("\n\n\n\nUpdating table with the following places")
            for place in actualObject{
                print("\(place.comment ?? "No comment")")
            }
        } else {
            print("no data")
        }
        
        //Populate the table accordingly
        if places.count == 0 {
            noSpotsLabel.setHidden(false)
            sendNotificationButton.setHidden(true)
        } else {
            noSpotsLabel.setHidden(true)
            locationInterfaceTable.setNumberOfRows(places.count, withRowType:"default")
            
            for idx in 0 ... places.count-1 {
                let row = locationInterfaceTable.rowController(at: idx) as! LocationTableRowController
                let placeName = places[idx].comment ?? "No Comment"
                row.locationLabel.setText(placeName)
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
        
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return places[rowIndex]
    }
    
    //If the user got here via a notification, 
    //Check the action identifier of the action and perform neccessary actions
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.actionIdentifier)
        print("We got here from a notification")
        if let location = response.notification.request.content.userInfo["newLocation"] {
            let locationObject = NSKeyedUnarchiver.unarchiveObject(with: location as! Data) as! FavoriteLocation
            print("The new location is: \(locationObject.comment ?? "No comment")")
            
            switch response.actionIdentifier {
            case "like":
                locationObject.likes += 1
                locationObject.record["Likes"] = locationObject.likes as CKRecordValue?
                WCSessionManager.sharedInstance.sendLocationForUpdate(locationObject: locationObject)
                break
            case "dislike":
                locationObject.dislikes += 1
                locationObject.record["Dislikes"] = locationObject.dislikes as CKRecordValue?
                WCSessionManager.sharedInstance.sendLocationForUpdate(locationObject: locationObject)
                break
            default:
                return
            }
            pushController(withName: "mapInterfaceController", context: locationObject)
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

