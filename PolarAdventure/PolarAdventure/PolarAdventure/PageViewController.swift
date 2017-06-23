//
//  PageViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 04/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

// Attribution: https://www.youtube.com/watch?v=oX9o-DnMHsE

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    //MARK: Varialbes
    
    var currentPage = 0
    let defaults = UserDefaults.standard
    
    lazy var pageArray: [UIViewController] = [self.getVC(name: "page_one"), self.getVC(name: "page_two"), self.getVC(name: "page_three"), self.getVC(name: "page_four"), self.getVC(name: "page_five"), self.getVC(name: "page_six"), self.getVC(name: "page_seven")]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        
        //Getting the bookmark from user default. 
        //Bookmark is a int that is the index of the bookmarked page in the pageArray
        var pageIndex = 0
        if let index = defaults.object(forKey: "bookmark") {
            pageIndex = index as! Int
        }
        let firstPage = pageArray[pageIndex]
        setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = pageArray.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard pageArray.count > previousIndex else {
            return nil
        }
        
        return pageArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = pageArray.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pageArray.count else {
            return nil
        }
        
        guard nextIndex > 0 else {
            return nil
        }
        
        return pageArray[nextIndex]
    }
    
    //Instantiate a view controller using it's name (identifier)
    private func getVC(name: String) -> UIViewController{
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
}
