//
//  TodayViewController.swift
//  TodayFavorites
//
//  Created by Isabel  Lee on 25/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  Attribution: http://stackoverflow.com/questions/39683238/ios10-widget-show-more-show-less-bug

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: - Variable
    var appList: [[String:Any]] = []
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let sharedAppGroup: String = "group.isabeljlee.ItunesSearchData"
        let sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
        if let appSummary = sharedDefaults?.array(forKey: "favoriteSummary") as! [[String:Any]]? {
            appList = appSummary
        }
        dump(appList)
        tableView.reloadData()
    }

    func numberOfSections(in: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TodayTableViewCell
        cell.appNameLabel.text = appList[indexPath.row]["trackName"] as? String
        cell.iconImageView.image = UIImage(data: appList[indexPath.row]["icon"] as! Data)
        return cell
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        //This launch string was configured in Target > ItunesSearch > Info > Url types
        let launchString = "com.isabeljlee.itunesSearch://appId=\(appList[row]["trackId"]!)"
        self.extensionContext?.open(URL(string: launchString)!, completionHandler:nil)
    }
    
}

extension TodayViewController : NCWidgetProviding {
    
    //The today widget sometimes show a "There is no active animation block" error and fails to load
    //This is a alternative fix for the found on stackoverflow
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize){
        if (activeDisplayMode == NCWidgetDisplayMode.compact) {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = maxSize
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.preferredContentSize = CGSize(width: 0, height: 400)
            }, completion: nil)
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        self.tableView.reloadData()
        completionHandler(NCUpdateResult.newData)
    }
}
