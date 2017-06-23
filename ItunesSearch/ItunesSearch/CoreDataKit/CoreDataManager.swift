//
//  CoreDataManager.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 25/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import CoreData


// override the default location of the core data store
// to use the app groups
final class PersistentContainer: NSPersistentContainer {
    
    internal override class func defaultDirectoryURL() -> URL {
        var url = super.defaultDirectoryURL()
        if let newURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.isabeljlee.ItunesSearchData") {
            url = newURL
        }
        return url
    }
    
    override init(name: String, managedObjectModel model: NSManagedObjectModel) {
        super.init(name: name, managedObjectModel: model)
    }
}

// A singlton used to manage storing/retrieving data from core data.
public class CoreDataManager: NSObject, NSFetchedResultsControllerDelegate {
    
    public static let sharedInstance = CoreDataManager()
    
    var dataContext: NSManagedObjectContext? {
        return persistentContainer.viewContext
    }
    
    var favoriteAppList:[App] = []
    var favoriteSummary:[[String:Any]] = []

    
    // MARK: Core Data stack
    lazy public var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let kitBundle = Bundle(identifier: "com.isabeljlee.CoreDataKit")
        
        //momd is the compiled model file extension
        let modelURL = kitBundle?.url(forResource: "Model", withExtension: "momd")
        let m = NSManagedObjectModel(contentsOf: modelURL!)!
        
        
        let container = NSPersistentContainer(name: "ItunesSearchCoreData", managedObjectModel: m )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        let context = persistentContainer.viewContext

        if context.hasChanges {
            do {
                try context.save()

            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetching and Filtering results from core data
    
    lazy var fetchedResultsController: NSFetchedResultsController<Keyword> = {
        let fetchRequest = NSFetchRequest<Keyword>(entityName: "Keyword")
        fetchRequest.fetchBatchSize = 10
        fetchRequest.predicate = NSPredicate(format: "TRUEPREDICATE")
        let dateDescriptor = NSSortDescriptor(key: "app", ascending: false)
        fetchRequest.sortDescriptors = [dateDescriptor]
        
        let _fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: self.persistentContainer.viewContext,
                                                                   sectionNameKeyPath: "app",
                                                                   cacheName: nil)
        _fetchedResultsController.delegate = self
        return _fetchedResultsController
        
    }()
    
    // Fetch all the keywords matching the search term, then retrieve the app that is associate to that keyword
    // Make sure that each app is only returned once in a search.
    public func filterResult(predicate: NSPredicate) -> [App] {
        print("Fetching result using coreData kit")
        var appList: [App] = []
        do {
            fetchedResultsController.fetchRequest.predicate = predicate
            try self.fetchedResultsController.performFetch()
        } catch {
            let nserror = error as NSError
            print("An error occured: \(nserror), \(nserror.userInfo)")
        }
        for object in fetchedResultsController.sections! {
            
            for keyword in object.objects! {
                let app = ((keyword as! Keyword).app)!
                if !appList.contains(app) {
                    appList.append(app)
                }
            }
        }
        
        if appList != [] {
            self.favoriteAppList = appList
            updateSummary()
        }
        return appList
    }
    
    //Retrieve the app with matching id from core data
    public func fetchAppById(id: Int32) -> App? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "App")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try dataContext?.fetch(request)
            if (results?.count)! > 0 {
                for result in results as! [NSManagedObject]{
                    if let appId = result.value(forKey: "trackId") as? Int32 {
                        print("\(appId)")
                        if appId == id {
                            return result as? App
                        }
                    }
                }
            }
        }catch{
            print("Did not succeed")
        }
        return nil
    }
    
    //Because the today extension often don't load fast enough to retrieve app list from core data, 
    //The summary is updated in user defaluts whenever the wishlist is launched or when the user searches the
    //Wishlist. And the today extension reads and displays the items stored in User Defaults
    func updateSummary() {
        self.favoriteSummary = []
        print("Updating summary")
        var itemCount = 5
        if self.favoriteAppList.count < 5 {
            itemCount = self.favoriteAppList.count
        }
        for i in 0..<itemCount {
            self.favoriteSummary.append(["trackName":self.favoriteAppList[i].trackName!, "icon": self.favoriteAppList[i].icon!, "trackId": self.favoriteAppList[i].trackId])
        }
        
        let sharedAppGroup: String = "group.isabeljlee.ItunesSearchData"
        let sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
        sharedDefaults?.set(favoriteSummary, forKey: "favoriteSummary")
    }
    
//    //Return an array of dictionaries, containing at most 5 wish list apps, 
//    public func getTodayFavorite() -> [[String: Any]]{
//        return self.favoriteSummary
//    }
    
    
    //Add an app to Core data
    public func addWishListItem(appInfo: [String:Any], appIcon: UIImage) {

        let date = Date()
        let calendar = Calendar.current
        
        let wishListApp = App(context: dataContext!)
        wishListApp.appDescription = appInfo["description"] as? String
        wishListApp.artistName = appInfo["artistName"] as? String
        wishListApp.artworkUrl100 = appInfo["artworkUrl100"] as? String
        wishListApp.averageUserRating = appInfo["averageUserRating"] as? String
        wishListApp.screenshotUrls = appInfo["screenshotUrls"] as? NSObject
        wishListApp.trackId = (appInfo["trackId"] as? Int32)!
        wishListApp.trackName = appInfo["trackName"] as? String
        wishListApp.icon =  NSData(data: UIImagePNGRepresentation(appIcon)!)
        wishListApp.timestamp = "\(calendar.component(.year, from: date))/\(calendar.component(.month, from: date))/\(calendar.component(.day, from: date))"
        wishListApp.formattedPrice = appInfo["formattedPrice"] as? String

        // To store an UIImage as NSData, must use this method rather than casting it directly
        let keywords = generateKeyword(description: (appInfo["description"] as? String)!) + generateKeyword(description: (appInfo["trackName"] as? String)!)
        dump(keywords)
        for keyword in keywords {
            let keywordItem = Keyword(context: dataContext!)
            keywordItem.keyword = keyword
            keywordItem.app = wishListApp
            wishListApp.addToKeywords(keywordItem)
        }
        print("Save using coredata kit")
        saveContext()
    }
    
    //From the descripion, generate keywords from the nouns in the description using NSLunguistic trigger
    func generateKeyword(description: String) -> [String]{
        
        var keywords:[String] = []
        let options = NSLinguisticTagger.Options.omitWhitespace.rawValue | NSLinguisticTagger.Options.joinNames.rawValue
        let tagger = NSLinguisticTagger(tagSchemes: NSLinguisticTagger.availableTagSchemes(forLanguage: "en"), options: Int(options))
        
        tagger.string = description
        let range = NSRange(location: 0, length: description.utf16.count)
        tagger.enumerateTags(in: range, scheme: NSLinguisticTagSchemeNameTypeOrLexicalClass, options: NSLinguisticTagger.Options(rawValue: options)) { tag, tokenRange, sentenceRange, stop in
            let token = (description as NSString).substring(with: tokenRange)
            if tag == "Noun" {
                keywords.append(token)
            }
        }
        return Array(Set(keywords))
    }
}
