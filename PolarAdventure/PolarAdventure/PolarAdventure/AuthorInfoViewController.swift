//
//  AuthorInfoViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 05/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

class AuthorInfoViewController: UIViewController {
    
    //MARK: Properties
    
    @IBAction func tapToDismiss(_ sender: UIButton) {
        self.dismiss(animated: true) {
            print("Dismiss Author Page")
        }
    }
    
    @IBOutlet weak var text: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        text.text = "Hi, I'm Isabel. Thank you for reading the Polar Adventure book! I hope you had as much fun reading it as I had writting it. Oh by the way, there are some easter eggs hidden in this app. Tap around and you may find some interesting things! Have fun!"
        
        text.font = text.font.withSize(25)
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
    }
}
