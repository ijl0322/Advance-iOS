//
//  mapViewController.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.

//  MARK: - Attribution
//  http://stackoverflow.com/questions/15292318/mkmapview-mkpointannotation-tap-event
//  http://stackoverflow.com/questions/5648169/howto-detect-tap-on-map-annotaition-pin

import UIKit
import MapKit
import CoreLocation
import CloudKit
import UserNotifications

class MapViewController: UIViewController {
    let manager = CLLocationManager()
    var currentLoacation:CLLocationCoordinate2D? = CLLocation(latitude: 37.4, longitude: -122.03).coordinate
    var nearByLocationList: [FavoriteLocation] = []
    let center = UNUserNotificationCenter.current()
    var count = 0
    
    @IBOutlet weak var map: MKMapView!
    
    //Allow the users to manually refresh nearby locations
    @IBAction func fetchNearby(_ sender: UIButton) {
        updateSpots()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        //manager.startUpdatingLocation()
        manager.startMonitoringSignificantLocationChanges()
        
        map.delegate = self
        
        WCSessionManager.sharedInstance.startSession()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addLocationSegue" {
            let vc = segue.destination as! AddLocationViewController
            vc.currentLocation = CLLocation(latitude: (currentLoacation?.latitude)!, longitude: (currentLoacation?.longitude)!)
        }
    }
    
    //Fetch nearby locations user the user's current location
    //Send the data to watch whenever this method is called
    func updateSpots() {
        print("Fetching spots from Cloud Kit")
        removeAllLocationNotification(locationList: nearByLocationList)
        let location = CLLocation(latitude: (currentLoacation?.latitude)!, longitude: (currentLoacation?.longitude)!)
        ClouldKitManager.sharedInstance.fetchLocations(center: location, meterRadius: 100000, completion: { (locations, error) in
            if error != nil {
                print(error ?? "no error")
            }
            
            DispatchQueue.main.async {
                self.nearByLocationList = locations
                self.removeAllLocationNotification(locationList: self.nearByLocationList)
                for place in self.nearByLocationList {
                    self.addAnnotationIn(favoriteLocation: place)
                    self.addLocationBaseNotification(location: place)
                }
                print("We got \(locations.count) places")
                self.sendToWatch()
            }
        })
    }
    
    //Archieve the list of favorite locations to send to the watch using WCSessions
    //Because of the limitation on the size of the payload,
    //the photo of all favorite location is set to nil
    func sendToWatch() {
        var sendToWatchLocations: [FavoriteLocation] = []
        for place in nearByLocationList {
            sendToWatchLocations.append(place)
        }
        
        for place in sendToWatchLocations {
            place.photo = nil
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: sendToWatchLocations)
        do {
            try WCSessionManager.sharedInstance.updateApplicationContext(["hello" : data as AnyObject])
        } catch {
            print("some error occured")
        }
    }
    
    @IBAction func unwindToMapVC(_ segue: UIStoryboardSegue) {
        updateSpots()
    }
    
    func addLocationBaseNotification(location: FavoriteLocation) {
        let content = UNMutableNotificationContent()
        content.title = "Discover Awesome spots!"
        content.body = "\(location.comment ?? "A spot") is nearby!"
        let identifier = location.record.recordID.recordName
        let region = CLCircularRegion(center: location.location!.coordinate, radius: 100000, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print("An Error Occured: \(error)")
            } else {
                print("Location based notification is added for spot \(location.comment ?? "No comment")")
            }
        })
    }
    
    func removeAllLocationNotification(locationList: [FavoriteLocation]) {
        for location in locationList {
            center.removePendingNotificationRequests(withIdentifiers: [location.record.recordID.recordName])
            print("removing location notification for \(location.comment ?? "no comment")")
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("location did change")
        let location = locations[0]
        let span = MKCoordinateSpanMake(0.5, 0.5)
        let myLocation = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region = MKCoordinateRegionMake(myLocation, span)
        currentLoacation = myLocation
        map.setRegion(region, animated: true)
        map.showsUserLocation = true
        updateSpots()
        
    }
}

extension MapViewController: MKMapViewDelegate{
    func addAnnotationIn(favoriteLocation: FavoriteLocation) {
        let annotation = MapAnnotation(title: favoriteLocation.comment!,
                                       subtitle: "", coordinate: (favoriteLocation.location?.coordinate)!, favoriteLocation: favoriteLocation)
        
        map.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MapAnnotation {
            let identifier = "CustomPin"
            
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                let likeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                likeButton.setImage(UIImage(named: "Happy"), for: .normal)
                likeButton.tag = 1
                let hateButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
                hateButton.tag = 2
                hateButton.setImage(UIImage(named: "Sad"), for: .normal)
                view.rightCalloutAccessoryView = likeButton
                view.leftCalloutAccessoryView = hateButton
            }
            configureDetailView(annotationView: view, annotation: annotation)
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Pin tapped")
        
        let annotation = view.annotation as! MapAnnotation
        let activity = NSUserActivity(activityType: "com.isabeljlee.spotSpotSpots/location")
        activity.title = annotation.favoriteLocation?.comment
        activity.mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate,
                                                            addressDictionary: nil))
        activity.becomeCurrent()
        self.userActivity = activity
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //print(view.annotation!.title ?? "no title" )
        print(control.tag)
        let clickedAnnotation = view.annotation as! MapAnnotation
        switch control.tag {
        case 1:
            clickedAnnotation.favoriteLocation?.likes += 1
            clickedAnnotation.favoriteLocation?.record["Likes"] = clickedAnnotation.favoriteLocation?.likes as CKRecordValue?
            ClouldKitManager.sharedInstance.update(records: [(clickedAnnotation.favoriteLocation?.record)!])
            likedSpot(liked: true)
        case 2:
            clickedAnnotation.favoriteLocation?.dislikes += 1
            clickedAnnotation.favoriteLocation?.record["Dislikes"] = clickedAnnotation.favoriteLocation?.dislikes as CKRecordValue?
            ClouldKitManager.sharedInstance.update(records: [(clickedAnnotation.favoriteLocation?.record)!])
            likedSpot(liked: false)
        default:
            return
        }
    }
    
    //Configure the map's annotation view to display a image
    func configureDetailView(annotationView: MKAnnotationView, annotation: MapAnnotation) {
        let width = 200.0
        let height = 200.0
        var image = annotation.favoriteLocation?.photo
        if image == nil {
            image = UIImage(named: "Like")
        }
        
        let snapshotView = UIView()
        let views = ["snapshotView": snapshotView]
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(200)]", options: [], metrics: nil, views: views))
        snapshotView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(200)]", options: [], metrics: nil, views: views))
        
        let options = MKMapSnapshotOptions()
        options.size = CGSize(width: width, height: height)
        options.mapType = .satelliteFlyover
        
        let snapshotter = MKMapSnapshotter(options: options)
        snapshotter.start { snapshot, error in
            if snapshot != nil {
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: width, height: height))
                imageView.image = image
                imageView.contentMode = .scaleAspectFill
                imageView.layer.masksToBounds = true
                imageView.layer.cornerRadius = imageView.frame.width/2
                snapshotView.addSubview(imageView)
            }
        }
        annotationView.detailCalloutAccessoryView = snapshotView
    }
    
    //Present a alert controller when a user rates a spot
    func likedSpot(liked: Bool) {
        var message = ""
        if liked{
            message = "Thanks for the like!"
        } else {
            message = "Thanks for the dislike!"
        }
        let alert = UIAlertController(title: "You Rated this spot",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default,
                                   handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}



