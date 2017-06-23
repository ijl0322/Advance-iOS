# Itunes Search

## Features

The app allows the user to brows apps and save their favorites. 
When a user clicks on a app, a detail view controller will show them more detail about the app.
Swip left/ right to view different screenshots in the detail view controller. 
The detail view controller also has an auto resizing scrollview that allows the user to read long app descriptions by scrolling up and down.

If the user is searching for an app, and there is no network connection, a UIAlertController is presented to notify the user.
Items in the table from previous search will still be available, but their screenshots will be replaced by a placeholder image.

If the user is using the itunes store share extension to add apps to their wishlist, and there was an issue connecting to the itunes store, the app simply waits till the next time the wishlist view controller is loaded and tries again. 

In the main app, all data are stored in Core Data, but data are passed to and from the app to its extensions using User Defaults, 
because reading and writting to user defaults seem to have a lighter overhead for the extensions and load faster. 



## Attribution

https://www.youtube.com/watch?v=zZJpsszfTHM

https://www.youtube.com/watch?v=qt8BNhpEAok

http://stackoverflow.com/questions/29825604/how-to-save-array-to-coredata

http://stackoverflow.com/questions/27624331/unique-values-of-array-in-swift

http://nshipster.com/nslinguistictagger/

https://www.cocoanetics.com/2015/03/implementing-an-in-app-app-store/

http://stackoverflow.com/questions/433907/how-to-link-to-apps-on-the-app-store/32008404#32008404

http://stackoverflow.com/questions/39683238/ios10-widget-show-more-show-less-bug

