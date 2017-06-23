//
//  LocationListViewController.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 08/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController {
    
    var favoriteList: [FavoriteLocation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        ClouldKitManager.sharedInstance.fetchALL(completion: {(favoriteLocations, error) in
            DispatchQueue.main.async {
                self.favoriteList = favoriteLocations
                print(favoriteLocations.count)
                self.tableView.reloadData()
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationDetailSegue" {
            let vc = segue.destination as! LocationDetailViewController
            let selectedRow = self.tableView.indexPathForSelectedRow!.row
            vc.favoriteLocation = favoriteList[selectedRow]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteList.count
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LocationTableViewCell
        cell.locationLabel.text = favoriteList[indexPath.row].comment
        return cell
    }

}
