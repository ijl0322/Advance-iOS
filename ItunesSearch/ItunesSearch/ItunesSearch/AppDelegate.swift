//
//  AppDelegate.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 18/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  Attribution: https://www.youtube.com/watch?v=izrtCEprIWo

import UIKit
import CoreData
import CoreDataKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?
    static let applicationShortcutUserInfoIconKey = "applicationShortcutUserInfoIconKey"
    var appList:[App] = []


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if((window?.traitCollection.forceTouchCapability) != nil){
            print("\(window!.rootViewController!.traitCollection.forceTouchCapability)")
        }
        
        //If the app was launched using a url (from the Today Favorites extension)
        //Parse URL and luanch the Wish List Detail Controller
        if let options = launchOptions {
            let url = options[UIApplicationLaunchOptionsKey.url] as! URL
            self.lauchWishListBy(url: url)
        }
        
        
        //Dynamically adding 3D touch items
        if application.shortcutItems != nil {
            
            appList = CoreDataManager.sharedInstance.filterResult(predicate: NSPredicate(format: "TRUEPREDICATE"))
            var shortCutList: [UIMutableApplicationShortcutItem] = []
            var numShortCuts = 3
            if appList.count < numShortCuts {
                numShortCuts = appList.count
            }

            for index in 0..<numShortCuts {
                let shortcut = UIMutableApplicationShortcutItem(type: "com.isabeljlee.ItunesSearch.app\(index)", localizedTitle: appList[index].trackName!, localizedSubtitle: appList[index].formattedPrice!, icon: UIApplicationShortcutIcon(templateImageName: "none"), userInfo: [
                    AppDelegate.applicationShortcutUserInfoIconKey: index
                ])
                shortCutList.append(shortcut)
            }
            
            application.shortcutItems = shortCutList
        }
        return true
    }
    
    //If the app was launched using a url (from the Today Favorites extension)
    //Parse URL and luanch the Wish List Detail Controller
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        self.lauchWishListBy(url: url)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let rootVC = window!.rootViewController as? UITabBarController else {
            return
        }
        print("\(shortcutItem.type)")
        
        //Handle when a shortcut item is being tapped
        if shortcutItem.type == "com.isabeljlee.ItunesSearch.search" {
            print("first item clicked")
            rootVC.selectedIndex = 0
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let wishListDetailViewController = storyboard.instantiateViewController(withIdentifier: "wishListDetailViewController") as! WishListDetailViewController
            
            guard let appIndex = shortcutItem.userInfo?[AppDelegate.applicationShortcutUserInfoIconKey] as? Int else { return }
            wishListDetailViewController.app = appList[appIndex]
            rootVC.present(wishListDetailViewController, animated: true, completion: nil)
        }
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {        
        let managedObjectModel: NSManagedObjectModel = {
            let coreDataFrameworkBundleIdentifier = "com.isabeljlee.CoreDataKit"
            let customKitBundle = Bundle(identifier: coreDataFrameworkBundleIdentifier)!
            let modelURL = customKitBundle.url(forResource: "Model", withExtension: "momd")!
            return NSManagedObjectModel(contentsOf: modelURL)!
        }()
        
        let container = NSPersistentContainer(name: "ItunesSearchCoreData", managedObjectModel: managedObjectModel )
        
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

    func saveContext () {
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
    
    //Parse the url used to launch the app, and launch the WishList Detail View Controller with proper information
    func lauchWishListBy(url: URL) {
        guard let rootVC = window!.rootViewController as? UITabBarController else {
            return
        }
        
        print("The application was launched from the url: \(url)")
        let urlString = "\(url)"
        let char = urlString.characters
        let range = char.index(char.startIndex, offsetBy: 36)..<char.index(char.endIndex, offsetBy: 0)
        print("Parsed id: \(urlString[range])")
        let app = CoreDataManager.sharedInstance.fetchAppById(id: Int32(urlString[range])!)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let wishListDetailViewController = storyboard.instantiateViewController(withIdentifier: "wishListDetailViewController") as! WishListDetailViewController
        
        wishListDetailViewController.app = app
        rootVC.present(wishListDetailViewController, animated: true, completion: nil)
    }

}


