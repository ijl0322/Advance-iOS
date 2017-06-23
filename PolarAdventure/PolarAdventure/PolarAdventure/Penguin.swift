//
//  PenguinWalk.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 05/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.

// Attribution: http://www.appcoda.com/ios-programming-animation-uiimageview/


import UIKit

protocol penguinStatusDelegate: class {
    func penguinHasJumped()
}

// A subclass of UIImageView, shows a penguin image, and has different functions for different animations.

class Penguin: UIImageView, UIGestureRecognizerDelegate {
    
    //MARK: Variables
    var delegate: penguinStatusDelegate?
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var penguinSize = 0.0
    var iceBergLeftBound =  0.0
    var iceBergRightBound = 0.0
    let step = 30.0
    let penguinFrame: CGRect?
    
    var animator:UIDynamicAnimator!
    var gravity:UIGravityBehavior!
    var push: UIPushBehavior!
    
    //MARK: Animation Images
    let walkRightImg = [UIImage(named: "penguin_walk1")!,UIImage(named: "penguin_walk2")!, UIImage(named: "penguin_walk3")!, UIImage(named: "penguin_walk4")!]
    let walkLeftImg = [UIImage(named: "penguin_l_walk1")!,UIImage(named: "penguin_l_walk2")!, UIImage(named: "penguin_l_walk3")!, UIImage(named: "penguin_l_walk4")!]
    let dizzyImg = [UIImage(named: "penguin_dizzy1")!, UIImage(named: "penguin_dizzy2")!]
    let lookImg = [UIImage(named: "penguin_walk1")!,UIImage(named: "penguin_look")!]
    let scaredImg = [UIImage(named: "penguin_scare1")!,UIImage(named: "penguin_scare2")!, UIImage(named: "penguin_scare3")!,UIImage(named: "penguin_scare2")!]
    let talkImg = [UIImage(named: "penguin_talk1")!, UIImage(named: "penguin_talk2")!, UIImage(named: "penguin_talk3")!, UIImage(named: "penguin_talk4")!]

    
    init(x penguinXPosition: Double, y penguinYPosition: Double) {
        penguinSize = screenWidth * 0.15
        iceBergLeftBound = screenWidth * 0.73
        iceBergRightBound = screenWidth * 0.25
        penguinFrame = CGRect(x: penguinXPosition, y: penguinYPosition, width: penguinSize, height: penguinSize)
        super.init(frame: penguinFrame!)
        
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        self.image = walkRightImg[0]
        self.animationImages = walkRightImg
        self.animationDuration = 0.8 / 2
        self.animationRepeatCount = 2
    }
    
    //MARK: Animations
    //Move penguin to its original position
    
    //Animate the penguin to swim dizzily in the ocean
    func dizzySwim() {
        self.image = self.dizzyImg[1]
        self.animationImages = self.dizzyImg
        self.animationRepeatCount = 10
        self.startAnimating()
        
        let animation = CABasicAnimation(keyPath: "transform")
        animation.fromValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: 30, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.toValue = NSValue(caTransform3D: CATransform3DMakeRotation(CGFloat(Measurement(value: -30, unit: UnitAngle.degrees).converted(to: .radians).value), 0, 0.0, 1.0))
        animation.duration = 0.2
        animation.repeatCount = 10
        animation.autoreverses = true
        self.layer.add(animation, forKey: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.layer.removeAllAnimations()
            self.animationRepeatCount = 2
        }
    }
    
    //Animate the penguin to talk
    func talk() {
        self.image = self.talkImg[0]
        self.animationImages = self.talkImg
        self.animationRepeatCount = 5
        self.animationDuration = 1
        self.startAnimating()
    }
    
    //Animte the penguin to look at the shark
    func lookAtShark() {
        self.image = self.lookImg[1]
        self.animationImages = self.lookImg
        self.animationRepeatCount = 5
        self.animationDuration = 1
        self.startAnimating()
    }
    
    //Animate the penguin to walk left
    func walkLeft() {
        self.image = self.walkLeftImg[0]
        self.animationImages = walkLeftImg
        self.startAnimating()
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            if Double(self.center.x) - self.step > self.iceBergRightBound{
                self.center.x -= CGFloat(self.step)
            }
        }, completion: nil)
    }
    
    //Animate the penguin to walk right
    func walkRight() {
        self.image = self.walkRightImg[0]
        self.animationImages = walkRightImg
        self.startAnimating()
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            if Double(self.center.x) + self.step < self.iceBergLeftBound{
                self.center.x += CGFloat(self.step)
            }
        }, completion: nil)
    }
    
    //Animate teh penguin to panic and be scared
    func scared() {
        self.image = self.scaredImg[0]
        self.animationImages = scaredImg
        self.animationRepeatCount = 5
        self.animationDuration = 1
        self.startAnimating()
    }
    
    //Animate the penguin to be helped by the shark and slowly move back to the iceberg
    func beHelped() {
        UIView.animate(withDuration: 2, delay: 0, options: .curveEaseOut, animations: {
            self.center.x = CGFloat(self.screenWidth * 0.35)
            self.center.y = CGFloat(self.screenHeight * 0.45)
        }, completion: nil)
    }
    
    //Animate the penguin to jump into water
    func jump() {
        self.image = UIImage(named: "penguin_up")
        UIView.animate(withDuration: 1, animations: {
            self.center.x = CGFloat(self.screenWidth*0.68)
            self.center.y = CGFloat(self.screenWidth*0.24)
            self.transform = CGAffineTransform(rotationAngle: (150.0 * CGFloat(Double.pi)) / 180.0)
        }, completion: { (finish) in
            
            self.animator = UIDynamicAnimator(referenceView: self.superview!)
            self.gravity = UIGravityBehavior(items: [self])
            self.animator.addBehavior(self.gravity)
            
            self.push = UIPushBehavior(items: [self], mode: .instantaneous)
            self.push.pushDirection = CGVector(dx: self.screenHeight*0.02, dy: self.screenHeight*0.045)
            self.animator.addBehavior(self.push)
            
            let itemBehaviour = UIDynamicItemBehavior(items: [self])
            itemBehaviour.resistance = 8
            self.animator.addBehavior(itemBehaviour)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.animator.removeBehavior(self.gravity)
                self.animator.removeBehavior(self.push)
                self.delegate?.penguinHasJumped()
            }
        })
    }
    
    func toStartPosition() {
        self.frame = penguinFrame!
        self.image = walkRightImg[1]
    }
    
    //MARK: Gesture Recognizers
    
    //Add swipe left/swipe left gesture to move the penguin around
    func addSwipe() {
        let swipeLeftGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
        swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirection.right
        
        self.addGestureRecognizer(swipeLeftGestureRecognizer)
        self.addGestureRecognizer(swipeRightGestureRecognizer)
    }
    
    //When swiped left, animate the penguin to walk left
    func swipeLeft(_ recognizer: UISwipeGestureRecognizerDirection){
        self.image = self.walkLeftImg[0]
        self.animationImages = walkLeftImg
        self.startAnimating()
        
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            if Double(self.center.x) - (self.step * 3) > 0{
                self.center.x -= CGFloat(self.step * 2)
            }
        }, completion: nil)
    }
    
    //When swiped right, animate the penguin to walk right
    func swipeRight(_ recognizer: UISwipeGestureRecognizerDirection){
        self.image = self.walkRightImg[0]
        self.animationImages = walkRightImg
        self.startAnimating()
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseOut, animations: {
            if Double(self.center.x) + (self.step * 2) < self.screenWidth{
                self.center.x += CGFloat(self.step * 2)
            }
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
