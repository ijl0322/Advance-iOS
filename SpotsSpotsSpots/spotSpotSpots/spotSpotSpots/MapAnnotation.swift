//
//  MapAnnotation.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import MapKit

//Custom map annotation
class MapAnnotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    var image: UIImage?
    let favoriteLocation: FavoriteLocation?
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, favoriteLocation: FavoriteLocation) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.image = UIImage(named: "Like")
        self.favoriteLocation = favoriteLocation
        super.init()
    }
}
