//
//  SharkSwim.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 05/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit
// A subclass of UIImageView, shows a shark image, and has different functions for different animations.
class Shark: UIImageView {
    
    
    //MARK: Variables
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var sharkYPosition = 0.0
    var sharkXPosition = 0.0
    var sharkSize = 0.0
    var iceBergLeftBound =  0.0
    var iceBergRightBound = 0.0
    var sharkFrame: CGRect?
    let step = 30.0
    
    var swimImg = [UIImage(named: "shark_swim1")!,UIImage(named: "shark_swim2")!]
    var talkImg = [UIImage(named: "shark_talk2")!, UIImage(named: "shark_talk3")!]
    var confusedImg = [UIImage(named: "shark_confused1")!, UIImage(named: "shark_confused2")!]
    var upImg = [UIImage(named: "shark_confused1")!, UIImage(named: "shark_up")!]
    
    init(x sharkXPosition: Double, y sharkYPosition: Double) {
        sharkSize = screenWidth * 0.3
        iceBergLeftBound = screenWidth * 0.73
        iceBergRightBound = screenWidth * 0.25
        sharkFrame = CGRect(x: sharkXPosition, y: sharkYPosition, width: sharkSize, height: sharkSize)
        
        super.init(frame: sharkFrame!)
        
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.image = swimImg[0]
        self.animationImages = swimImg
        self.animationDuration = 0.4
        self.animationRepeatCount = 10
    }
    
    //Move the shark to it's original position before any animation happened
    func toStartPosition() {
        self.frame = sharkFrame!
        self.image = swimImg[0]
    }
    
    //MARK: Animations
    //Animate the shark talking
    func talk() {
        self.image = talkImg[0]
        self.animationImages = talkImg
        self.startAnimating()
    }
    
    //Animate the shark to swim near the iceberg
    func startSwim() {
        self.image = swimImg[0]
        self.animationImages = swimImg
        self.animationDuration = 0.4
        self.animationRepeatCount = 10
        self.startAnimating()
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(self.iceBergLeftBound)
        }, completion: nil)
    }
    
    //Animate the shark to be confused
    func confused() {
        self.image = confusedImg[0]
        self.animationImages = confusedImg
        self.animationDuration = 0.8
        self.animationRepeatCount = 5
        self.startAnimating()
    }
    
    //Animate the shark to push the penguin back to the iceberg
    func helpPenguin() {
        self.image = upImg[0]
        self.animationImages = upImg
        self.animationDuration = 0.4
        self.animationRepeatCount = 10
        self.startAnimating()
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(self.screenWidth * 0.4)
            self.center.y = CGFloat(self.screenHeight * 0.55)
        }, completion: nil)
    }
    
    //Animate the shark to hit the iceberg
    func hitIceBerg() {
        self.startAnimating()
        
        //Swim to the iceberg
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(self.screenWidth/2 + self.sharkSize*0.47)
        }, completion: { (finish) in
            self.stopAnimating()
            self.image = UIImage(named: "shark_hit")
            
            //Hit the iceberg and animate reaction force
            UIView.animate(withDuration: 0.3, animations: {
                self.transform = CGAffineTransform(rotationAngle: (-30.0 * CGFloat(Double.pi)) / 180.0)
            }, completion: {(finish) in
                UIView.animate(withDuration: 0.5, animations: {
                    self.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
                }, completion: nil)
            })
        })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
