//
//  Narwhale.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 07/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

//A subclass of UIImageView, shows a narwhale that swims across the screen
class Narwhale: UIImageView {
    
    //MARK: Variables
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var narwhaleYPosition = 0.0
    var narwhaleSize = 0.0
    var narwhaleFrame: CGRect?
    var isSwimming = false
    
    var swimImg = [UIImage(named: "narwhale1")!,UIImage(named: "narwhale2")!, UIImage(named: "narwhale3")!,UIImage(named: "narwhale4")!]
    
    init() {
        narwhaleSize = screenWidth * 0.5
        narwhaleFrame = CGRect(x: screenWidth, y: screenHeight * 0.6, width: narwhaleSize, height: narwhaleSize)
        
        super.init(frame: narwhaleFrame!)
        
        self.contentMode = .scaleAspectFit
        self.image = swimImg[0]
        self.animationImages = swimImg
        self.animationDuration = 0.8
        self.animationRepeatCount = 0
    }
    
    //Move the narwhale back to staring position
    func toStartPosition() {
        self.frame = narwhaleFrame!
        self.image = swimImg[0]
    }
    
    //Animate the narwhale to rotate slightly when swimming. Giving a more realistic swimming animation
    func swimAnimation() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: 5, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: -5, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.duration = 0.8
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        self.layer.add(animation, forKey: "swim")
    }
    
    //Start the narwhale's swimming animation
    func startSwim() {
        if isSwimming {
            return
        }
        swimAnimation()
        isSwimming = true
        self.startAnimating()
        self.alpha = 1
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(-400)
        }, completion: {(finish) in
            self.toStartPosition()
            self.isSwimming = false
            self.alpha = 0
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

