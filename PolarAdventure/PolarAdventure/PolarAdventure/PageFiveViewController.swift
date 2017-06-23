//
//  PageFiveViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

class PageFiveViewController: UIViewController, UIGestureRecognizerDelegate {

    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var storyLineLength = 0.0
    var storyLineXPosition = 0.0
    var storyLineYPosition = 0.0
    var story: UILabel?
    var penguin: Penguin?
    var shark: Shark?
    var playButton: UIButton?
    let fishView = FishView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = UIButton(frame: CGRect(x: 100, y: 10, width: 80, height: 80))
        playButton?.setImage(UIImage(named: "soundButton"), for: .normal)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(playButton!)
        
        penguin = Penguin(x: screenWidth * 0.4, y: screenHeight * 0.35)
        shark = Shark(x: screenWidth * 0.1, y: screenHeight * 0.4)
        
        storyLineLength = screenWidth*0.8
        storyLineXPosition = screenWidth*0.1
        storyLineYPosition = screenHeight*0.1
        story = UILabel(frame: CGRect(x: storyLineXPosition, y: storyLineYPosition, width: storyLineLength, height: 150))
        
        story?.attributedText = ReadToMe.player.pageFiveString
        story?.lineBreakMode = .byWordWrapping
        story?.numberOfLines = 0
        story?.sizeToFit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharkTapped(_:)))
        tapGestureRecognizer.delegate = self
        shark!.addGestureRecognizer(tapGestureRecognizer)
        

        self.view.addSubview(fishView)
        self.view.addSubview(story!)
        self.view.addSubview(shark!)
        self.view.addSubview(penguin!)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fishView.toStartPosition()
        shark!.toStartPosition()
        penguin!.toStartPosition()
        penguin!.image = UIImage(named: "penguin_l_walk1")
        shark!.image = UIImage(named: "shark_talk1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults.standard.set(4, forKey: "bookmark")
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
    
    //Animate the shark to talk when it is tapped
    func sharkTapped(_ recognizer: UITapGestureRecognizer) {
        shark?.talk()
    }
    
    func playButtonTapped(_ button: UIButton){
        ReadToMe.player.pageFive(storyLabel: story!)
    }
    
    func isReadToMeOn() {
        if let readToMe = UserDefaults.standard.object(forKey: "readToMe") {
            print("readtome option: \(readToMe)")
            if readToMe as! Bool{
                print("Read to me")
                ReadToMe.player.pageFive(storyLabel: story!)
            }
        }
    }
}
