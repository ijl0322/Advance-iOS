//
//  FishView.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Attribution: http://liujinlongxa.com/2016/07/10/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3CoreAnimation%E7%9A%84fillMode%E5%92%8CisRemovedOnCompletion/

// Attribution: http://stackoverflow.com/questions/37819903/ios-layer-animation-explanation
// Attribution: http://ronnqvi.st/controlling-animation-timing/



import UIKit

//A subview that shows five fish swimming at different speed.
class FishView: UIView {
    
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var fish1: UIImageView?
    var fish2: UIImageView?
    var fish3: UIImageView?
    var fish4: UIImageView?
    var fish5: UIImageView?
    var fish1Frame: CGRect?
    var fish2Frame: CGRect?
    var fish3Frame: CGRect?
    var fish4Frame: CGRect?
    var fish5Frame: CGRect?
    
    init() {
        super.init(frame: CGRect(x: 0, y: screenHeight/2, width: screenWidth, height: screenHeight))
        self.isUserInteractionEnabled = true
        addFish()
    }

    //Animate all the fish to start swimming at different speed
    func startSwim() {
        
        UIView.animate(withDuration: 2, animations: {
            self.fish1!.center.x = -50
        }, completion: {(finish) in
            self.swim(fish: self.fish1!, speed: 6)
        })
        
        UIView.animate(withDuration: 3, animations: {
            self.fish2!.center.x = -50
        }, completion: {(finish) in
            self.swim(fish: self.fish2!, speed: 5.8)
        })
        
        UIView.animate(withDuration: 6, animations: {
            self.fish3!.center.x = -50
        }, completion: {(finish) in
            self.swim(fish: self.fish3!, speed: 5.7)
        })
        
        UIView.animate(withDuration: 5.4, animations: {
            self.fish4!.center.x = -50
        }, completion: {(finish) in
            self.swim(fish: self.fish4!, speed: 5.4)
        })
        
        UIView.animate(withDuration: 3.7, animations: {
            self.fish5!.center.x = -50
        }, completion: {(finish) in
            self.swim(fish: self.fish5!, speed: 5.5)
        })

    }
    
    
    //Animate all the fish to flee and disappear on the screen
    func flee() {
        
        //Get the position of the CA presentation layer
        let fish1Current = fish1!.layer.presentation()?.position
        let fish2Current = fish2?.layer.presentation()?.position
        let fish3Current = fish3?.layer.presentation()?.position
        let fish4Current = fish4?.layer.presentation()?.position
        let fish5Current = fish5?.layer.presentation()?.position
        
        //Move the fish's position to the CA presentation layer's position
        self.fish1?.center = fish1Current!
        self.fish2?.center = fish2Current!
        self.fish3?.center = fish3Current!
        self.fish4?.center = fish4Current!
        self.fish5?.center = fish5Current!
        
        //If this code is not delayed, it may accidently remove the fleeing animation
        //and give weird results
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.fish1?.layer.removeAllAnimations()
            self.fish2?.layer.removeAllAnimations()
            self.fish3?.layer.removeAllAnimations()
            self.fish4?.layer.removeAllAnimations()
            self.fish5?.layer.removeAllAnimations()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.animateFlee()
            }
        }
    }
    
    //Add the fleeing animation for the fish
    func animateFlee(){
        UIView.animate(withDuration: 1.5, animations: {
            self.fish1!.center.x = -400
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.fish2!.center.x = -50
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.fish3!.center.x = -70
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.fish4!.center.x = -200
        }, completion: nil)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.fish5!.center.x = -300
        }, completion: nil)
    }
    
    //Move all the fish back to starting position
    func toStartPosition() {
        fish1!.frame = fish1Frame!
        fish2!.frame = fish2Frame!
        fish3!.frame = fish3Frame!
        fish4!.frame = fish4Frame!
        fish5!.frame = fish5Frame!
    }
    
    //A a swimming animation to fish at a certain speed
    func swim(fish: UIImageView, speed: Double) {
        let position = CABasicAnimation(keyPath: "position.x")
        position.fromValue = screenWidth
        position.toValue = 0
        position.duration = speed
        position.autoreverses = false
        position.repeatCount = Float.infinity
        fish.layer.add(position, forKey: "swim")
    }
    
    //Add all the fish to the view
    func addFish() {
        fish1Frame = CGRect(x: screenWidth*0.065, y: screenHeight*0.22, width: screenWidth*0.08, height: screenHeight*0.08)
        fish2Frame = CGRect(x: screenWidth*0.27, y: screenHeight*0.34, width: screenWidth*0.08, height: screenHeight*0.08)
        fish3Frame = CGRect(x: screenWidth*0.83, y: screenHeight*0.41, width: screenWidth*0.08, height: screenHeight*0.08)
        fish4Frame = CGRect(x: screenWidth*0.72, y: screenHeight*0.15, width: screenWidth*0.08, height: screenHeight*0.08)
        fish5Frame = CGRect(x: screenWidth*0.46, y: screenHeight*0.07, width: screenWidth*0.08, height: screenHeight*0.08)
        
        fish1 = UIImageView(frame: fish1Frame!)
        fish2 = UIImageView(frame: fish2Frame!)
        fish3 = UIImageView(frame: fish3Frame!)
        fish4 = UIImageView(frame: fish4Frame!)
        fish5 = UIImageView(frame: fish5Frame!)
        
        fish1?.contentMode = .scaleAspectFit
        fish2?.contentMode = .scaleAspectFit
        fish3?.contentMode = .scaleAspectFit
        fish4?.contentMode = .scaleAspectFit
        fish5?.contentMode = .scaleAspectFit
        
        fish1?.image = UIImage(named: "fish1")
        fish2?.image = UIImage(named: "fish2")
        fish3?.image = UIImage(named: "fish3")
        fish4?.image = UIImage(named: "fish4")
        fish5?.image = UIImage(named: "fish5")
        
        self.addSubview(fish1!)
        self.addSubview(fish2!)
        self.addSubview(fish3!)
        self.addSubview(fish4!)
        self.addSubview(fish5!)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
