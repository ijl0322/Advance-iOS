//
//  FavoriteLocation.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 08/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation
import CloudKit


//A Subclass of NSObject that store the favorite location information we got from cloudkit's public database.
@objc(FavoriteLocation)
class FavoriteLocation: NSObject, NSCoding {
    var comment: String?
    var location: CLLocation?
    var likes = 0
    var dislikes = 0
    var photo: UIImage?
    var record: CKRecord!
    
    
    init(record: CKRecord) {
        super.init()
        self.record = record
        self.comment = record["Comment"] as? String
        self.location = record["Location"] as? CLLocation
        self.likes = (record["Likes"] as? Int)!
        self.dislikes = (record["Dislikes"] as? Int)!
        self.photo = UIImage(named: "Like")
        self.loadCoverPhoto(record: record)
    }
    
    //Cast the CKAsset correctly to get the image
    func loadCoverPhoto(record: CKRecord) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
            var image: UIImage!
            guard let asset = record["Photo"] as? CKAsset else {
                return
            }
            
            let imageData: Data
            do {
                imageData = try Data(contentsOf: asset.fileURL)
            } catch {
                return
            }
            image = UIImage(data: imageData)
            DispatchQueue.main.async {
                self.photo = image
                print("image downloaded")
            }
        }
    }
    
    //Implemented to allow this object to be archieved and sent to the watch via WCSession
    required init(coder aDecoder: NSCoder) {
        self.comment = aDecoder.decodeObject(forKey: "comment") as? String
        self.likes = Int(aDecoder.decodeCInt(forKey: "likes"))
        self.dislikes = Int(aDecoder.decodeCInt(forKey: "dislikes"))
        self.photo = aDecoder.decodeObject(forKey: "photo") as? UIImage
        self.record = aDecoder.decodeObject(forKey: "record") as? CKRecord
        self.location = aDecoder.decodeObject(forKey: "location") as? CLLocation
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.comment, forKey: "comment")
        aCoder.encode(self.likes, forKey: "likes")
        aCoder.encode(self.dislikes, forKey: "dislikes")
        aCoder.encode(self.location, forKey: "location")
        aCoder.encode(self.photo, forKey: "photo")
        aCoder.encode(self.record, forKey: "record")
    }
}
