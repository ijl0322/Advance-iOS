//
//  Beluga.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 08/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//


import UIKit

//A subclass of UIImageView, shows a beluga that swims across the screen
class Beluga: UIImageView {
    
    //MARK: Variables
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var belugaYPosition = 0.0
    var belugaSize = 0.0
    var belugaFrame: CGRect?
    var isSwimming = false
    
    var swimImg = [UIImage(named: "beluga1")!,UIImage(named: "beluga2")!, UIImage(named: "beluga3")!,UIImage(named: "beluga4")!]
    
    init() {
        belugaSize = screenWidth * 0.4
        belugaFrame = CGRect(x: screenWidth, y: screenHeight * 0.45, width: belugaSize, height: belugaSize)
        
        super.init(frame: belugaFrame!)
        
        self.contentMode = .scaleAspectFit
        self.image = swimImg[0]
        self.animationImages = swimImg
        self.animationDuration = 1.2
        self.animationRepeatCount = 0
    }
    
    
    //MARK: Animations
    //Move the narwhale back to staring position
    func toStartPosition() {
        self.frame = belugaFrame!
        self.image = swimImg[0]
    }
    
    //Animate the beluga to rotate slightly when swimming. Giving a more realistic swimming animation
    func swimAnimation() {
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: 5, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: -5, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.duration = 1.2
        animation.repeatCount = Float.infinity
        animation.autoreverses = true
        self.layer.add(animation, forKey: "swim")
    }
    
    //Start the beluga's swimming animation
    func startSwim() {
        if isSwimming {
            return
        }
        swimAnimation()
        isSwimming = true
        self.startAnimating()
        UIView.animate(withDuration: 10, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(-400)
        }, completion: {(finish) in
            self.toStartPosition()
            self.isSwimming = false
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
