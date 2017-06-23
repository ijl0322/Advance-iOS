//
//  SearchAppDetailViewController.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 20/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  Attribution: https://www.youtube.com/watch?v=zZJpsszfTHM
//  Attribution: https://www.youtube.com/watch?v=qt8BNhpEAok
//  Attribution: http://stackoverflow.com/questions/29825604/how-to-save-array-to-coredata
//  Attribution: http://stackoverflow.com/questions/27624331/unique-values-of-array-in-swift

// Attribution: http://nshipster.com/nslinguistictagger/
// Attribution: https://www.andrewcbancroft.com/2015/08/25/sharing-a-core-data-model-with-a-swift-framework/
// Attribution: http://stackoverflow.com/questions/25088367/how-to-use-core-datas-managedobjectmodel-inside-a-framework

import UIKit
import NetworkingKit
import StoreKit
import CoreData
import CoreDataKit

class SearchAppDetailViewController: UIViewController, UIScrollViewDelegate, SKStoreProductViewControllerDelegate {
    
    //MARK: Variables
    var descriptionLabel: UILabel!
    var scrollView: UIScrollView!
    var appInfo: [String:Any]?
    var appIcon: UIImage?
    var screenShots: [UIImage] = []
    var numScreenShots = 0
    
    //MARK: Properties
    //Use segmented control to toggle between showing screenshots and descriptions
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            scrollView.alpha = 0
        case 1:
            scrollView.alpha = 1
        default:
            return
        }
    }
    
    //Lauches SKStoreProduct vc to allow the user to buy the app in the app store
    @IBAction func buyApp(_ sender: UIBarButtonItem) {
            let store = SKStoreProductViewController()
            store.delegate = self
            let param = [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: appInfo?["trackId"] as! Int)]
            store.loadProduct(withParameters: param, completionBlock: {
                (success, error) -> Void in

                if success == true{
                    self.present(store, animated: true, completion: nil)
                    print("succes")
                }
                else{
                    print("error")
                }
            })
    }

    //Creates a new App entity to store the current app in the wishList
    //Also generate keywords using NSLinguistic Trigger and add the keyword entities
    @IBAction func saveToWishList(_ sender: UIBarButtonItem) {
        CoreDataManager.sharedInstance.addWishListItem(appInfo: appInfo!, appIcon: appIcon!)
    }
    
    @IBOutlet weak var pageControll: UIPageControl!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var screenShotImageView: UIImageView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.view.frame.width - 20, height: self.view.frame.height))
        
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        scrollView.backgroundColor = UIColor.white
        scrollView.alpha = 0
        
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        screenShotImageView.isUserInteractionEnabled = true
        screenShotImageView.addGestureRecognizer(swipeLeftGestureRecognizer)
        screenShotImageView.addGestureRecognizer(swipeRightGestureRecognizer)

        descriptionLabel?.lineBreakMode = .byWordWrapping
        descriptionLabel?.numberOfLines = 0
        descriptionView.addSubview(scrollView)
        scrollView.addSubview(descriptionLabel!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        iconImage.image = appIcon!
        appNameLabel.text = appInfo?["trackName"] as? String
        developerLabel.text = appInfo?["artistName"] as? String
        ratingsLabel.text = appInfo?["averageUserRating"] as? String
        priceLabel.text = appInfo?["formattedPrice"] as? String
        descriptionLabel.text = appInfo?["description"] as? String
        descriptionLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: descriptionLabel.frame.width, height: descriptionLabel.frame.height + 400)
        downloadScreenShots(urls: appInfo?["screenshotUrls"]! as! [String])
    }
    
    //Change screenshot images when swiped left
    func swipeLeft(_ recognizer: UISwipeGestureRecognizerDirection){
        
        if pageControll.currentPage < numScreenShots {
            pageControll.currentPage += 1
            screenShotImageView.image = screenShots[pageControll.currentPage]
        }
    }
    
    //Change screenshot images when swiped right
    func swipeRight(_ recognizer: UISwipeGestureRecognizerDirection){
        
        if pageControll.currentPage > 0 {
            pageControll.currentPage -= 1
            screenShotImageView.image = screenShots[pageControll.currentPage]
        }
    }
    
    //Given an array of url strings, download all the images and append them to the array screenShots
    func downloadScreenShots(urls: [String]){
        for url in urls {
            SharedItunesApi.sharedInstance.downloadPhoto(imgUrl: url, completion: { (image) in
                DispatchQueue.main.async {
                    self.screenShots.append(image!)
                    self.screenShotImageView.image = self.screenShots[0]
                    self.pageControll.currentPage = 0
                    self.pageControll.numberOfPages = self.screenShots.count
                    self.numScreenShots = self.screenShots.count
                }
            })
        }
    }
    
    //Generate keywords from the description using NSLinguistic trigger
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
