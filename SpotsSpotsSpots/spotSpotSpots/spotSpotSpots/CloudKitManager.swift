//
//  CloudKitManager.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 08/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  MARK: - Attribution
//  http://stackoverflow.com/questions/36969341/how-to-properly-send-an-image-to-cloudkit-as-ckasset

// https://forums.developer.apple.com/thread/26195


import Foundation
import CloudKit
import CoreLocation
import UIKit

class ClouldKitManager {
    
    // MARK: - Properties
    let FavoriteLocationRecordType = "FavoriteLocation"
    static let sharedInstance = ClouldKitManager()
    var items: [FavoriteLocation] = []
    
    let container: CKContainer
    let publicDB: CKDatabase
    let privateDB: CKDatabase
    
    // MARK: - Initializers
    init() {
        container = CKContainer.default()
        publicDB = container.publicCloudDatabase
        privateDB = container.privateCloudDatabase
    }
    
    //Add a location to Cloudkit public database
    func addLocation(comment: String, location: CLLocation, image: UIImage?) {
        let record = CKRecord(recordType: FavoriteLocationRecordType)
        record["Comment"] = comment as CKRecordValue
        record["Likes"] = 0 as CKRecordValue
        record["Dislikes"] = 0 as CKRecordValue
        record["Location"] = location
        
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")
        
        //Saving Image to a temporary location, then get it back as an CKAsset object
        if let photo = image {
            let data = UIImageJPEGRepresentation(photo, 0.1)
            do {
                try data!.write(to: url!)
            } catch let e as NSError {
                print("Error! \(e)");
                return
            }
            record["Photo"] = CKAsset(fileURL: url!)
        }

        //Saving to public database
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            //Removing temporary files that were used to create the CKAsset
            do { try FileManager.default.removeItem(at: url!) }
            catch let e { print("Error deleting temp file: \(e)") }
            print("Saved record: \(record.debugDescription)")
        }
    }
    
    //Fetching locations from the public database closed to the center provided
    //Parameters:
    //  - center: the center of the search query
    //  - meterRadius: the radius (in meters) in which we are doing the search
    
    func fetchLocations(center: CLLocation,
                             meterRadius: CLLocationDistance,
                             completion: @escaping (_ results: [FavoriteLocation], _ error: Error?) -> ()) {
        

        let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f", "Location", center, meterRadius)
        
        let query = CKQuery(recordType: FavoriteLocationRecordType,
                            predicate:  locationPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { results, error in
            var result: [FavoriteLocation] = []
            
            guard let records = results else { return }
            
            for record in records {
                let establishment = FavoriteLocation(record: record)
                result.append(establishment)
            }
            
            completion(result, error)
        }
    }
    
    //Fetching all locations from the database
    func fetchALL(completion: @escaping (_ results: [FavoriteLocation], _ error: Error?) -> ()) {
        
        let locationPredicate = NSPredicate(format: "TRUEPREDICATE", "Location")
        
        let query = CKQuery(recordType: FavoriteLocationRecordType,
                            predicate:  locationPredicate)
        
        publicDB.perform(query, inZoneWith: nil) { results, error in
            var result: [FavoriteLocation] = []
            
            guard let records = results else { return }
            
            for record in records {
                let establishment = FavoriteLocation(record: record)
                result.append(establishment)
            }
            
            completion(result, error)
        }
    }
    
    //Given an array of CKRecords, update changed keys
    func update(records: [CKRecord]) {
        let modifyOperation = CKModifyRecordsOperation()
        modifyOperation.recordsToSave = records
        modifyOperation.savePolicy = .changedKeys
        modifyOperation.qualityOfService = .userInitiated
        modifyOperation.completionBlock = {
            print("value saved")
        }
        ClouldKitManager.sharedInstance.publicDB.add(modifyOperation)
    }
    
    //Fetches a record from the public database using record ID
    func fetchRecordWith(recordId: String, completion: @escaping (FavoriteLocation?) -> Void) {
        print("Fetching record")
        let zoneId = CKRecordZoneID(zoneName: "_defaultZone",
                                  ownerName: "_defaultOwner")
        let ckRecordId = CKRecordID(recordName: recordId,
                                    zoneID: zoneId)
        publicDB.fetch(withRecordID: ckRecordId, completionHandler: { (record, error) in
            print(record?["Comment"] ?? "No comment")
            if let error = error {
                print("Some error occured: \(error)")
                completion(nil)
            } else {
                completion(FavoriteLocation(record: record!))
            }        
        })
    }
    
    
    //Register a user to be receive a silent notification when a new spot is added
    //A custom local notification is created when the silent notification is received 
    func registerSilentSubscriptionsWithIdentifier(_ identifier: String) {
        
        let uuid: UUID = UIDevice().identifierForVendor!
        let identifier = "\(uuid)-silent"
        
        // Create the notification that will be delivered
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = ["Comment"]
        
        let subscription = CKQuerySubscription(recordType: "FavoriteLocation",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = notificationInfo
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: ({returnRecord, error in
            if let err = error {
                print("subscription failed \(err.localizedDescription)")
            } else {
                print("silent subscription set up")
            }
        }))
    }
}
