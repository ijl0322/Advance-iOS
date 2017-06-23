//
//  ParentGateViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 07/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Attribution: http://stackoverflow.com/questions/24003191/pick-a-random-element-from-an-array

import UIKit

enum ValidationError: Error {
    case WrongShape
    case WrongPenguin
    case Unknown
}

//Every time this view controller is presented, it selects a piece of ice at random, and asks the user to move the second penguin onto that ice. If the user picks the wrong penguin or wrong ice, it will randomly choose another ice. If the user choses correctly, it will present the author info view controller.

class ParentGateViewController: UIViewController, UIGestureRecognizerDelegate{

    @IBAction func homeButton(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Variables
    
    let Bounds = Size()
    var screenWidth: Double = 0
    var screenHeight: Double = 0
    var iceWidth = 0.0
    var iceHeight = 0.0
    var iceSpacing = 0.0
    var iceYPosition = 0.0
    var penguinYPosition = 0.0
    var penguinSpacing = 0.0
    var penguinLeading = 0.0
    var penguinSize = 0.0
    var iceTriangle: UIImageView?
    var iceCircle: UIImageView?
    var iceHexagon: UIImageView?
    var penguinOne: UIImageView?
    var penguinTwo: UIImageView?
    var penguinThree: UIImageView?
    var penguinOneFrame: CGRect?
    var penguinTwoFrame: CGRect?
    var penguinThreeFrame: CGRect?
    var text: UILabel?
    var randomIce: UIImageView?
    
    //MARK: Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenWidth = Bounds.screenWidth
        screenHeight = Bounds.screenHeight
        let storyLineLength = screenWidth*0.8
        let storyLineXPosition = screenWidth*0.1
        
        text = UILabel(frame: CGRect(x: storyLineXPosition, y: 100, width: storyLineLength, height: 150))
        text?.textColor = UIColor(red: 6/255, green: 51/255, blue: 124/255, alpha: 1)
        text?.font = text?.font.withSize(30)
        text?.textAlignment = .left
        text?.lineBreakMode = .byWordWrapping
        text?.numberOfLines = 0
        self.view.addSubview(text!)
        
        setUpIce()
        setUpPenguins()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        pickRandomIce()
        toStartPosition()
    }
    
    //MARK: Custom Methods
    
    func pickRandomIce() {
        let iceList = [iceCircle, iceHexagon, iceTriangle]
        let randomIndex = Int(arc4random_uniform(3))
        print("\(randomIndex)")
        randomIce = iceList[randomIndex]
        setText(randomIceIndex: randomIndex)
    }
    
    func setText(randomIceIndex: Int) {
        var shape = ""
        switch randomIceIndex {
        case 0:
            shape = "circular"
        case 1:
            shape = "hexagon"
        case 2:
            shape = "triangular"
        default:
            return
        }
        text?.text = "Drag the second penguin onto the \(shape) shaped ice"
    }
    
    func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        
        guard let penguin = recognizer.view else {
            print("Cannot unwrap penguin")
            return
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            do {
                try validate(penguin: penguin)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.showAuthorInfo()
                }
            } catch {
                print("\(error)")
                pickRandomIce()
            }
        }
    }
    
    // Validate whether the user has completed the parental gate task
    func validate(penguin: UIView) throws{
        switch penguin.tag {
        case 1:
            penguin.frame = penguinOneFrame!
            throw ValidationError.WrongPenguin
        case 3:
            penguin.frame = penguinThreeFrame!
            throw ValidationError.WrongPenguin
        case 2:
            if (penguin.frame).intersects(randomIce!.frame.insetBy(dx: 40.0, dy: 40.0)) {
                penguin.center.x = randomIce!.center.x + 10
                penguin.center.y = randomIce!.center.y - 40
                return
                
            } else {
                penguin.frame = penguinTwoFrame!
                throw ValidationError.WrongShape
            }
        default:
            throw ValidationError.Unknown
        }
    }
    
    //Move the penguins back to their original position
    func toStartPosition() {
        penguinOne?.frame = penguinOneFrame!
        penguinTwo?.frame = penguinTwoFrame!
        penguinThree?.frame = penguinThreeFrame!
    }
    
    //Present the Author Info View Controller when called
    func showAuthorInfo() {
        let vc = AuthorInfoViewController()
        self.present(vc, animated: true) {
            print("Author Info presented")
        }
    }
    
    //MARK: Set Up
    
    //Set up and position the ice on the main view
    private func setUpIce() {
        iceWidth = screenWidth * 0.25
        iceHeight = iceWidth/2
        iceSpacing = screenWidth * 0.0625
        iceYPosition = screenHeight * 0.3
        
        iceCircle = UIImageView(frame: CGRect(x: iceSpacing, y: iceYPosition, width: iceWidth, height: iceHeight))
        iceHexagon = UIImageView(frame: CGRect(x: iceSpacing*2 + iceWidth*1, y: iceYPosition, width: iceWidth, height: iceHeight))
        iceTriangle = UIImageView(frame: CGRect(x: iceSpacing*3 + iceWidth*2, y: iceYPosition, width: iceWidth, height: iceHeight))
        
        iceCircle?.image = UIImage(named: "ice_circle")
        iceTriangle?.image = UIImage(named: "ice_triangle")
        iceHexagon?.image = UIImage(named: "ice_hexagon")
        
        iceCircle?.isUserInteractionEnabled = true
        iceTriangle?.isUserInteractionEnabled = true
        iceHexagon?.isUserInteractionEnabled = true
        
        self.view.addSubview(iceTriangle!)
        self.view.addSubview(iceCircle!)
        self.view.addSubview(iceHexagon!)
    }
    
    //Set up and position the ice on the main view
    private func setUpPenguins() {
        penguinSize = screenWidth * 0.2
        penguinLeading = screenWidth * 0.15
        penguinSpacing = screenWidth * 0.05
        penguinYPosition = screenHeight * 0.8
        
        penguinOneFrame = CGRect(x: penguinLeading, y: penguinYPosition, width: penguinSize, height: penguinSize)
        penguinTwoFrame = CGRect(x: penguinLeading + penguinSize + penguinSpacing, y: penguinYPosition, width: penguinSize, height: penguinSize)
        penguinThreeFrame = CGRect(x: penguinLeading + penguinSize*2 + penguinSpacing*2, y: penguinYPosition, width: penguinSize, height: penguinSize)
        
        penguinOne = UIImageView(frame: penguinOneFrame!)
        penguinTwo = UIImageView(frame: penguinTwoFrame!)
        penguinThree = UIImageView(frame: penguinThreeFrame!)
        
        penguinOne?.contentMode = .scaleAspectFit
        penguinTwo?.contentMode = .scaleAspectFit
        penguinThree?.contentMode = .scaleAspectFit
        
        penguinOne?.tag = 1
        penguinTwo?.tag = 2
        penguinThree?.tag = 3
        
        penguinOne?.isUserInteractionEnabled = true
        penguinTwo?.isUserInteractionEnabled = true
        penguinThree?.isUserInteractionEnabled = true
        
        penguinOne?.image = UIImage(named: "penguin_walk1")
        penguinTwo?.image = UIImage(named: "penguin_walk1")
        penguinThree?.image = UIImage(named: "penguin_walk1")
        
        for penguin in [penguinOne!, penguinTwo!, penguinThree!] {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
            panGestureRecognizer.delegate = self
            penguin.addGestureRecognizer(panGestureRecognizer)
        }
        
        self.view.addSubview(penguinOne!)
        self.view.addSubview(penguinTwo!)
        self.view.addSubview(penguinThree!)
    }
}
