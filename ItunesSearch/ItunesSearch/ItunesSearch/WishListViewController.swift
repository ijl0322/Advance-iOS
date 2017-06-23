//
//  WishListViewController.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 22/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import CoreData
import CoreDataKit
import NetworkingKit

class WishListViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Varialbes
    var currentPredicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")
    var appList: [App] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    var context: NSManagedObjectContext? {
        return CoreDataManager.sharedInstance.persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //Reloads apps from Core Data everytime the view is about to appear, so that any new likes will show up properly
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let sharedAppGroup: String = "group.isabeljlee.ItunesSearchData"
        let sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
        if let appId = sharedDefaults?.object(forKey: "newAppId") as? String{
            if appId != "" {
                SharedItunesApi.sharedInstance.lookUpAppBy(id: appId, completion: { (appInfo, error) in
                    DispatchQueue.main.async {
                        if error == nil {
                            print("\n\n\n\n\n\n\n\n Adding new app")
                            self.addNewAppToCoreData(appInfo: appInfo, error: error)
                            sharedDefaults?.set("", forKey: "newAppId")
                        }
                    }
                })
            }
        } else {
            print("\n\n\n\n\n\n\n\n No value in user defaults")
        }
        updateAppList()
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if (segue.identifier == "wishListDetailSegue") {
            
            let viewController = segue.destination as! WishListDetailViewController
            let selectedRow = self.tableView.indexPathForSelectedRow!.row
            viewController.app = appList[selectedRow]
        }
    }
    
    //Since we are filtering against the keyword entity, when there are multiple keyword matches, an app may appear multiple times, this function fetches the result and makes sure one app only appears once.
    func updateAppList(){
        appList = CoreDataManager.sharedInstance.filterResult(predicate: currentPredicate)
    }
    
    //Add a new app to core data (when the app is passed in from the Share Extension API via User Defaults
    //And reload table)
    func addNewAppToCoreData(appInfo: [[String:Any]], error: Error?) {
        SharedItunesApi.sharedInstance.downloadPhoto(imgUrl: (appInfo[0]["artworkUrl100"] as? String)!, completion: { (icon) in
            DispatchQueue.main.async {
                CoreDataManager.sharedInstance.addWishListItem(appInfo: appInfo[0], appIcon: icon!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3 , execute: {
                    self.updateAppList()
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set up each table using the data we fetched from core data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WishListTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "wishListCell", for: indexPath) as! WishListTableViewCell
        
        let app = appList[indexPath.row]
        cell.iconImage.image = UIImage(data: app.icon! as Data)
        cell.developerLabel.text = app.artistName
        cell.ratingsLabel.text = app.averageUserRating
        cell.appNameLabel.text = app.trackName
        cell.timestampLabel.text = app.timestamp
        return cell
    }
    
    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(160)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let app = appList[indexPath.row]
            
            guard let keywordList = app.keywords else{
                print("list is nil")
                return
            }

            for key in keywordList {
                let keyObject = key as! Keyword
                context?.delete(keyObject)
            }
            
            context?.delete(app)
            appList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do{
                try context?.save()
            } catch {
                print("Cannot delete app")
            }
        }
    }
    
}

extension WishListViewController: UISearchResultsUpdating, UISearchBarDelegate{
    
    //Filter wish list according to the text in the search bar
    func filterResultsForSearchText(keyword: String) {
        if keyword.characters.count == 0 {
            self.currentPredicate = NSPredicate(format: "TRUEPREDICATE")
        } else {
            self.currentPredicate = NSPredicate(format: "keyword CONTAINS[cd] %@", keyword)
        }
        updateAppList()
        tableView.reloadData()
    }
    
    //If the cancel button is clicked, show everything
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterResultsForSearchText(keyword: "")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        var keyword = ""
        if searchController.searchBar.text! != "" {
            keyword = searchController.searchBar.text!
        } else {
            return
        }
        filterResultsForSearchText(keyword: keyword)
    }
}

