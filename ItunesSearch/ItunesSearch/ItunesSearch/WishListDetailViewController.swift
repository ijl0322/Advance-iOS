//
//  WishListDetailViewController.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 22/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import NetworkingKit
import StoreKit
import CoreData
import CoreDataKit

class WishListDetailViewController: UIViewController, UIScrollViewDelegate, SKStoreProductViewControllerDelegate {

    //MARK: Variable
    var scrollView: UIScrollView!
    var descriptionLabel: UILabel!
    var screenShots: [UIImage] = []
    var numScreenShots = 0
    var app: App?
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    //MARK: Properties
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var developerLabel: UILabel!
    @IBOutlet weak var ratingsLabel: UILabel!
    @IBOutlet weak var screenShotImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    //Switches between showing the description and the screenshots
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            scrollView.alpha = 0
        case 1:
            scrollView.alpha = 1
        default:
            return
        }
    }
    
    //These two buttons are used when the View Controller is presented (not in the navigation controller hierachy)
    @IBAction func buyButtonTapped(_ sender: UIButton) {
        goToItunesStore()
    }
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Launches SKStoreProductViewController and allows the user to buy the app in the app store
    @IBAction func buyApp(_ sender: UIBarButtonItem) {
        goToItunesStore()
    }

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
        if self.isBeingPresented {
            backButton.alpha = 1
            buyButton.alpha = 1
        } else {
            backButton.alpha = 0
            buyButton.alpha = 0
        }
        
        iconImageView.image = UIImage(data: app!.icon! as Data)
        appNameLabel.text = app?.trackName
        developerLabel.text = app?.artistName
        ratingsLabel.text = app?.averageUserRating
        descriptionLabel.text = app?.appDescription
        priceLabel.text = app?.formattedPrice
        descriptionLabel.sizeToFit()
        scrollView.contentSize = CGSize(width: descriptionLabel.frame.width, height: descriptionLabel.frame.height + 400)
        downloadScreenShots(urls: app?.screenshotUrls as! [String])
    }
    
    //Use the NetworkingKit to download all photos in the urls array
    func downloadScreenShots(urls: [String]){
        for url in urls {
            SharedItunesApi.sharedInstance.downloadPhoto(imgUrl: url, completion: { (image) in
                DispatchQueue.main.async {
                    self.screenShots.append(image!)
                    self.screenShotImageView.image = self.screenShots[0]
                    self.pageControl.currentPage = 0
                    self.pageControl.numberOfPages = self.screenShots.count
                    self.numScreenShots = self.screenShots.count
                }
            })
        }
    }
    
    //Change screenshot pages when a user swipes left
    func swipeLeft(_ recognizer: UISwipeGestureRecognizerDirection){
        
        if pageControl.currentPage < numScreenShots {
            pageControl.currentPage += 1
            screenShotImageView.image = screenShots[pageControl.currentPage]
        }
    }
    
    //Change screenshot pages when a user swipes right
    func swipeRight(_ recognizer: UISwipeGestureRecognizerDirection){
        
        if pageControl.currentPage > 0 {
            pageControl.currentPage -= 1
            screenShotImageView.image = screenShots[pageControl.currentPage]
        }
    }
    
    //Present the SKStoreProductViewController, and use the app's trackId to present the correct app
    func goToItunesStore() {
        let store = SKStoreProductViewController()
        store.delegate = self
        let param = [SKStoreProductParameterITunesItemIdentifier: NSNumber(value: Int(app!.trackId))]
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
}
