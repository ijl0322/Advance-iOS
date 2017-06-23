//
//  SearchViewController.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 18/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  Attribution: https://www.cocoanetics.com/2015/03/implementing-an-in-app-app-store/
//  http://stackoverflow.com/questions/433907/how-to-link-to-apps-on-the-app-store/32008404#32008404

import UIKit
import StoreKit
import NetworkingKit

class SearchViewController: UIViewController, SKStoreProductViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Variables
    var searchTerm = "flappy"
    var appInfo: [[String:Any]] = []
    var appIcons: [UIImage] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchItunes()
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }

    //Use the NetworkingKit to search for apps and download app icons
    func searchItunes() {
         SharedItunesApi.sharedInstance.search(searchTerm: searchTerm, completion: { (result, error) in
            if error != nil {
                print("Networking error occured")
                DispatchQueue.main.async {
                    self.errorAlert()
                }
                return
            }
            DispatchQueue.main.async {
                self.appInfo = []
                self.appIcons = []
                for app in result {
                    SharedItunesApi.sharedInstance.downloadPhoto(imgUrl: (app["artworkUrl100"] as? String)!, completion: { (image) in
                        DispatchQueue.main.async {
                            self.appInfo.append(app)
                            self.appIcons.append(image!)
                            self.tableView.reloadData()
                        }
                    })
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        if (segue.identifier == "searchAppDetailSegue") {
            let viewController = segue.destination as! SearchAppDetailViewController
            let selectedRow = self.tableView.indexPathForSelectedRow!.row
            viewController.appInfo = appInfo[selectedRow]
            viewController.appIcon = appIcons[selectedRow]
            
        }
    }
    
    // present a UIAlertViewController to inform user that some problem occured
    func errorAlert() {
        let message = "Opps..Something bad happend"
        let alert = UIAlertController(title: "Please check your network connection",
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appInfo.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // set up each table using the data we go from the github API
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SearchAppTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "searchAppCell", for: indexPath) as! SearchAppTableViewCell
        
        cell.iconImageView.image = appIcons[indexPath.row]
        cell.developerLabel.text = appInfo[indexPath.row]["artistName"] as? String
        cell.ratingsLabel.text = appInfo[indexPath.row]["averageUserRating"] as? String
        //print("\(appInfo[indexPath.row]["averageUserRating"])")
        cell.appNameLabel.text = appInfo[indexPath.row]["trackName"] as? String
        return cell
    }
}

extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text! != "" && searchController.searchBar.text! != searchTerm {
            searchTerm = searchController.searchBar.text!
            searchItunes()
        } else {
            return
        }
    }
}
