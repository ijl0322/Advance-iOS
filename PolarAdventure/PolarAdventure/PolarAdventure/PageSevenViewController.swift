//
//  PageSevenViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Attribution: https://www.bignerdranch.com/blog/uidynamics-in-swift/
//  Attribution: https://www.raywenderlich.com/76147/uikit-dynamics-tutorial-swift
//  Attribution: https://www.raywenderlich.com/94719/uikit-dynamics-swift-tutorial-tossing-views


import UIKit

class PageSevenViewController: UIViewController, UIGestureRecognizerDelegate, penguinStatusDelegate {

    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var storyLineLength = 0.0
    var storyLineXPosition = 0.0
    var storyLineYPosition = 0.0
    var story: UILabel?
    var penguin: Penguin?
    var shark: Shark?
    var sharkAndPenguin: UIImageView?
    var playButton: UIButton?
    let fishView = FishView()
    let beluga = Beluga()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = UIButton(frame: CGRect(x: 100, y: 10, width: 80, height: 80))
        playButton?.setImage(UIImage(named: "soundButton"), for: .normal)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(playButton!)
        
        shark = Shark(x: screenWidth * 0.7, y: screenHeight * 0.7)
        sharkAndPenguin = UIImageView(frame: CGRect(x: screenWidth * 0.7, y: screenHeight * 0.7, width: screenWidth * 0.3, height: screenWidth * 0.3))
        sharkAndPenguin?.contentMode = .scaleAspectFit
        sharkAndPenguin?.image = UIImage(named: "sharkAndPenguin2")
        sharkAndPenguin?.isUserInteractionEnabled = true
        sharkAndPenguin?.alpha = 0
        
        storyLineLength = screenWidth*0.8
        storyLineXPosition = screenWidth*0.1
        storyLineYPosition = screenHeight*0.1
        story = UILabel(frame: CGRect(x: storyLineXPosition, y: storyLineYPosition, width: storyLineLength, height: 150))
        
        story?.attributedText = ReadToMe.player.pageSevenString
        story?.lineBreakMode = .byWordWrapping
        story?.numberOfLines = 0
        story?.sizeToFit()
    
        addEasterEgg()
        
        self.view.addSubview(fishView)
        self.view.addSubview(story!)
        self.view.addSubview(sharkAndPenguin!)
        self.view.addSubview(beluga)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(penguinTapped(_:)))
        tapGestureRecognizer.delegate = self
        penguin = Penguin(x: screenWidth * 0.35, y: screenHeight * 0.35)
        penguin?.delegate = self
        penguin!.addGestureRecognizer(tapGestureRecognizer)
        fishView.toStartPosition()
        shark!.toStartPosition()
        penguin!.toStartPosition()
        penguin?.alpha = 1
        shark?.alpha = 1
        sharkAndPenguin?.alpha = 0
        sharkAndPenguin!.frame = CGRect(x: screenWidth * 0.7, y: screenHeight * 0.7, width: screenWidth * 0.3, height: screenWidth * 0.3)
        self.view.addSubview(penguin!)
        self.view.addSubview(shark!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults.standard.set(6, forKey: "bookmark")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fishView.startSwim()
            self.isReadToMeOn()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        ReadToMe.player.removeAllTimer()
        SharedAudioPlayer.player.stopAllPlayer()
        ReadToMe.player.clearFormatting(storyLabel: story!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        penguin?.removeFromSuperview()
        shark?.removeFromSuperview()
    }
    
    //Animate the penguin to jump into the ocean and the shark and peugin to swim when the penguin is tapped
    func penguinTapped(_ recognizer: UITapGestureRecognizer) {
        penguin?.jump()
        if Random.generator.shouldShowBeluga() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.beluga.startSwim()
            }
        }
    }

    //Animate the shark to swim away with the penguin
    func swimAway() {
        let swimImg = [UIImage(named: "sharkAndPenguin1")!,UIImage(named: "sharkAndPenguin2")!]
        sharkAndPenguin?.animationImages = swimImg
        sharkAndPenguin?.animationDuration = 0.8
        sharkAndPenguin?.animationRepeatCount = 10
        sharkAndPenguin?.startAnimating()
        UIView.animate(withDuration: 6, delay: 0, options: .curveEaseOut, animations: {
            self.sharkAndPenguin?.center.x = -300
        }, completion: nil)
        
    }
    
    //Add gesture recognizer for the easter egg, which shows a beluga when the fishView is tapped three times.
    func addEasterEgg() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fishViewTapped(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 3
        fishView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func fishViewTapped(_ recognizer: UITapGestureRecognizer) {
        beluga.startSwim()
    }
    
    func penguinHasJumped() {
        penguin?.alpha = 0
        shark?.alpha = 0
        sharkAndPenguin?.alpha = 1
        swimAway()
    }
    
    func playButtonTapped(_ button: UIButton){
        ReadToMe.player.pageSeven(storyLabel: story!)
    }
    
    func isReadToMeOn() {
        if let readToMe = UserDefaults.standard.object(forKey: "readToMe") {
            print("readtome option: \(readToMe)")
            if readToMe as! Bool{
                print("Read to me")
                ReadToMe.player.pageSeven(storyLabel: story!)
            }
        }
    }
}
