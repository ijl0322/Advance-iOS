//
//  Size.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 04/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

//Size class: A singleton that gets the height and width of the User's screen,
//and stores it's width and height, so that it won't be calculated again and again.

class Size {
    
    static let shared = Size()
    let screenBounds = UIScreen.main.bounds
    let screenWidth: Double
    let screenHeight: Double
    init() {
        screenWidth = Double(screenBounds.width)
        screenHeight = Double(screenBounds.height)
    }
}
