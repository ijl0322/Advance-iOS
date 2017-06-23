//
//  PageFourViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

class PageFourViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var storyLineLength = 0.0
    var storyLineXPosition = 0.0
    var storyLineYPosition = 0.0
    var story: UILabel?
    var penguin: Penguin?
    var shark: Shark?
    let fishView = FishView()
    var playButton: UIButton?
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    @IBOutlet weak var instruction: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = UIButton(frame: CGRect(x: 100, y: 10, width: 80, height: 80))
        playButton?.setImage(UIImage(named: "soundButton"), for: .normal)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(playButton!)
        
        penguin = Penguin(x: screenWidth * 0.4, y: screenHeight * 0.55)
        shark = Shark(x: screenWidth * 0.5, y: screenHeight * 0.7)
        
        storyLineLength = screenWidth*0.8
        storyLineXPosition = screenWidth*0.1
        storyLineYPosition = screenHeight*0.1
        story = UILabel(frame: CGRect(x: storyLineXPosition, y: storyLineYPosition, width: storyLineLength, height: 150))
        
        story?.attributedText = ReadToMe.player.pageFourString
        story?.lineBreakMode = .byWordWrapping
        story?.numberOfLines = 0
        story?.sizeToFit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(penguinTapped(_:)))
        tapGestureRecognizer.delegate = self
        penguin!.addGestureRecognizer(tapGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(sharkDragged(_:)))
        panGestureRecognizer?.delegate = self
        shark!.addGestureRecognizer(panGestureRecognizer!)
        
        self.view.addSubview(fishView)
        self.view.addSubview(story!)
        self.view.addSubview(shark!)
        self.view.addSubview(penguin!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults.standard.set(3, forKey: "bookmark")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fishView.startSwim()
            self.isReadToMeOn()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.instruction.text = "Touch the penguin to see what happens!"
        fishView.toStartPosition()
        shark!.toStartPosition()
        penguin!.toStartPosition()
        penguin?.image = UIImage(named: "penguin_dizzy1")
        panGestureRecognizer?.isEnabled = false
    }
    
    //When the penguin is tapped, show the penguin to swim dizzily and the shark to look confused
    //When the animation is done, instruct the user to drag the shark to the penguin
    func penguinTapped(_ recognizer: UITapGestureRecognizer) {
        penguin?.dizzySwim()
        shark?.confused()
        SharedAudioPlayer.player.playEffect(name: "dizzy")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.panGestureRecognizer?.isEnabled = true
            self.instruction.text = "Now drag the shark to the penguin to help him!"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        ReadToMe.player.removeAllTimer()
        SharedAudioPlayer.player.stopAllPlayer()
        ReadToMe.player.clearFormatting(storyLabel: story!)
    }
    
    //When the user drags the shark and touches the penguin, animate the shark to help the penguin back to the iceberg
    func sharkDragged(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: recognizer.view)
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: recognizer.view)
        
        guard let shark = recognizer.view else {
            print("Cannot unwrap shark")
            return
        }
        
        if recognizer.state == UIGestureRecognizerState.ended {
            
            if (shark.frame).intersects(penguin!.frame.insetBy(dx: 10.0, dy: 10.0)) {
                print("OK")
                shark.center.x = CGFloat(screenWidth*0.5)
                shark.center.y = CGFloat(screenHeight*0.7)
                panGestureRecognizer?.isEnabled = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.shark!.helpPenguin()
                    self.penguin!.beHelped()
                }
            }
        }
    }
    
    func playButtonTapped(_ button: UIButton){
        ReadToMe.player.pageFour(storyLabel: story!)
    }
    
    func isReadToMeOn() {
        if let readToMe = UserDefaults.standard.object(forKey: "readToMe") {
            print("readtome option: \(readToMe)")
            if readToMe as! Bool{
                print("Read to me")
                ReadToMe.player.pageFour(storyLabel: story!)
            }
        }
    }
}
