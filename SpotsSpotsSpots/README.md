# Spots

Spots is a location based app that lets the user discover spots near them. 
In the iphone app, the user can view nearby location and all locations.

The nearby locations are displayed on a map, with pins and custom annotations showing the comment/photo of the location. 
When the user taps a pin, they can like/dislike a location. This does not continuously update the map based on the user's location.
The pins will only be refreshed when the user's location changes significantly, so it reduces battery draining. When the user adds a location, it may take a short while until the map updates. The user can manually update the map by tapping on "Fetch Nearby Location". Using the simulator's simulate freeway drive, the location gets update approximately once every minute.

Tapping on the "Add Current Location" button will allow the user to add their current location to the database with a comment and a photo. 

# Watch App

When the iPhone app refreshes (either because of significant location changes or the user manually refreshing it), the iPhone app sends an array of FavoriteLocation objcets to the watch via the WCSession. The objects will be temporarily stored in User Defaults, and when the watch Interface Controller becomes active, it will update its table accordingly. If an update happens while the watch Interface Controller is active, it will not update until the next time it becomes active. (This is assuming that the user will not be staring at their watch app while walking around and see if it updates live). 

# Notification

The user is subscribed to a silent notification that gets triggered when a new spot is added to the public database. 
When the silent notification is received, a local notification is created, and it will show the user more information (the comment) regarding the new spot. When the silent notification is received, the iPhone app makes a query via CloudKitManager, and retrieves the record that triggered the notification. A FavoriteLocation object is created using this record, and is added to the payload of the local notification. 

Since I was unable to test the notification on the watch app, at the bottom of the Interface Controller, I added a Send Notification button to simulate receiving this local notification from the iPhone. When tapped, the watch sends a local notification to itself, using the first location item in its table as the payload, and can handle like/dislike actions for this notification. 

# Adding locaitons as a suggestion for apple map

Attempted to use the following code for adding a location in apple map. Saddly it does not do anything other than displaying a tiny badge saying "Get Directions to Unknown Location in Maps Recently viewed in spotSpotSpots" that occasionally shows up when tapping home twice. 

```swift
        let annotation = view.annotation as! MapAnnotation
        let activity = NSUserActivity(activityType: "com.isabeljlee.spotSpotSpots/location")
        activity.title = annotation.favoriteLocation?.comment
        activity.mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate,
                                                            addressDictionary: nil))
        activity.becomeCurrent()
        self.userActivity = activity

```

# Attribution
http://stackoverflow.com/questions/15292318/mkmapview-mkpointannotation-tap-event

http://stackoverflow.com/questions/5648169/howto-detect-tap-on-map-annotaition-pin

http://stackoverflow.com/questions/36969341/how-to-properly-send-an-image-to-cloudkit-as-ckasset

https://forums.developer.apple.com/thread/26195

https://www.natashatherobot.com/watchkit-actionable-notifications/

https://makeapppie.com/2016/12/05/add-actions-and-categories-to-notification-in-swift/

https://developer.apple.com/library/content/documentation/DataManagement/Conceptual/CloudKitQuickStart/SubscribingtoRecordChanges/SubscribingtoRecordChanges.html

https://www.shinobicontrols.com/blog/ios8-day-by-day-day-36-location-notifications


