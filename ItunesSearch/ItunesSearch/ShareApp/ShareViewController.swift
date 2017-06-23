//
//  ShareViewController.swift
//  ShareApp
//
//  Created by Isabel  Lee on 25/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices
import NetworkingKit


class ShareViewController: SLComposeServiceViewController {
    
    var appUrl: URL?

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func presentationAnimationDidFinish() {

        let items = extensionContext?.inputItems
        var itemProvider: NSItemProvider?
        
        // Exit early if there are no items
        if items == nil && items!.isEmpty != false {
            print("did not receive item")
            return }
        
        // Get item
        let item = items![0] as! NSExtensionItem
        print("\n\n\n\n\n\n\n\nAttachment items: \(String(describing: items))")
        
        if let attachments = item.attachments {
            
            for attachment in attachments {
                itemProvider = attachment as? NSItemProvider
                
                // Get URL
                let urlType = kUTTypeURL as String
                if itemProvider?.hasItemConformingToTypeIdentifier(urlType) == true {
                    itemProvider?.loadItem(forTypeIdentifier: urlType, options: nil) { (item, error) -> Void in
                        if error == nil {
                            if let url = item as? URL {
                                print("🌎 URL: \(url)")
                                self.appUrl = url
                            }
                        }
                    }
                }
            }
        }
    }
    
    //When the user selects an app using the share extension, save the in user default and add that to core data 
    //when the user launches the app again
    //I decided to use user defaults because accessing core data in the extension seem to cause some level of instability, like apps show up a few minutes later, or not showing up at all. 
    //Not sure if its an implementation problem. But I was using the same function in the app and the extension
    //And only the extension has this kind of behavior.
    override func didSelectPost() {
        SharedItunesApi.sharedInstance.getAppIdFromUrl(url: self.appUrl!, completion: { (id) in
            DispatchQueue.main.async {
                let sharedAppGroup: String = "group.isabeljlee.ItunesSearchData"
                let sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
                sharedDefaults?.set(id, forKey: "newAppId")
                print("setting user default to id: \(id)")
            }
        })
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
