//
//  Random.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 13/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//
import UIKit

//Randomly decides when an ocean mammal should appear on screen

class Random {
    static let generator = Random()
    
    private init() {}
    
    //Generate a number between 0 - 4, if it's a 0, show the beluga
    func shouldShowBeluga() -> Bool {
        let randomNum = Int(arc4random_uniform(5))
        print("\(randomNum)")
        return false //randomNum == 0
    }
    
    //Generate a number between 0 - 2, if it's a 0, show the narwhale
    func shouldShowNarwhale() -> Bool {
        let randomNum = Int(arc4random_uniform(3))
        print("\(randomNum)")
        return false //randomNum == 0
    }
}
