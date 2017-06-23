//
//  ViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 04/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Putting ads: http://codewithchris.com/iad-tutorial/

import UIKit

//This is the root view controller, which is the welcome page when the app launches

class ViewController: UIViewController {
    
    //MARK: Variables
    
    let bounds = Size()
    var screenWidth = 0.0
    var screenHeight = 0.0
    var penguin: Penguin?
    
    //MARK: Properties
    
    //Presents the Parental Gate page
    @IBAction func authorButton(_ sender: UIButton) {
        let vc = ParentGateViewController()
        self.present(vc, animated: true) {
            print("Parental gate presented")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenWidth = bounds.screenWidth
        screenHeight = bounds.screenHeight
        penguin = Penguin(x: screenWidth * 0.25, y: screenHeight * 0.85)
        penguin!.addSwipe()
        self.view.addSubview(penguin!)
    }

    @IBAction func unwindToRVC(sender: UIStoryboardSegue) {
        print("Back at RVC")
    }
}

