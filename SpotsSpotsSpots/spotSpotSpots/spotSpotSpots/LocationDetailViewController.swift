//
//  LocationDetailViewController.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 08/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import MapKit

class LocationDetailViewController: UIViewController {
    
    var favoriteLocation: FavoriteLocation?
    @IBOutlet weak var locationCommentLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var dislikesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationCommentLabel.text = favoriteLocation?.comment
        if let photo = favoriteLocation?.photo {
            locationImage.image = photo
        }
        locationImage.layer.cornerRadius = locationImage.frame.width/2
        locationImage.layer.masksToBounds = true
        likesLabel.text = "Likes: \(favoriteLocation?.likes ?? 0)"
        dislikesLabel.text = "Dislikes: \(favoriteLocation?.dislikes ?? 0)"
        map.delegate = self
        addAnnotationIn(favoriteLocation: favoriteLocation!)
        let location = favoriteLocation?.location
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let myLocation = CLLocationCoordinate2DMake((location?.coordinate.latitude)!, (location?.coordinate.longitude)!)
        let region = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
    }
}

extension LocationDetailViewController: MKMapViewDelegate {
    func addAnnotationIn(favoriteLocation: FavoriteLocation) {
        let annotation = MapAnnotation(title: favoriteLocation.comment!,
                                       subtitle: "", coordinate: (favoriteLocation.location?.coordinate)!, favoriteLocation: favoriteLocation)
        
        map.addAnnotation(annotation)
    }
}
