//
//  PageTwoViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import UIKit

class PageTwoViewController: UIViewController, UIGestureRecognizerDelegate {

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
    
    @IBAction func walkRight(_ sender: UIButton) {
        penguin!.walkRight()
        shark!.startSwim()
    }
    
    @IBAction func walk(_ sender: UIButton) {
        shark!.talk()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = UIButton(frame: CGRect(x: 100, y: 10, width: 80, height: 80))
        playButton?.setImage(UIImage(named: "soundButton"), for: .normal)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(playButton!)
        
        penguin = Penguin(x: screenWidth * 0.6, y: screenHeight * 0.32)
        shark = Shark(x: screenWidth * 0.9, y: screenHeight * 0.7)
        
        storyLineLength = screenWidth*0.8
        storyLineXPosition = screenWidth*0.1
        storyLineYPosition = screenHeight*0.1
        story = UILabel(frame: CGRect(x: storyLineXPosition, y: storyLineYPosition, width: storyLineLength, height: 150))
        
        story?.attributedText = ReadToMe.player.pageTwoString
        story?.lineBreakMode = .byWordWrapping
        story?.numberOfLines = 0
        story?.sizeToFit()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(sharkTapped(_:)))
        tapGestureRecognizer.delegate = self
        shark!.addGestureRecognizer(tapGestureRecognizer)
        
        self.view.addSubview(fishView)
        self.view.addSubview(story!)
        self.view.addSubview(penguin!)
        self.view.addSubview(shark!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fishView.toStartPosition()
        shark!.toStartPosition()
        penguin!.toStartPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults.standard.set(1, forKey: "bookmark")
        fishView.toStartPosition()
        shark!.toStartPosition()
        penguin!.toStartPosition()
        
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
    
    //Animate the shark to start swimming and the penguin to look at the shark when the shark is tapped
    func sharkTapped(_ recognizer: UITapGestureRecognizer) {
        SharedAudioPlayer.player.playEffect(name: "sharkAppear")
        shark!.startSwim()
        penguin!.lookAtShark()
    }
    
    func playButtonTapped(_ button: UIButton){
        print("play sound")
        ReadToMe.player.pageTwo(storyLabel: story!)
    }
    
    func isReadToMeOn() {
        if let readToMe = UserDefaults.standard.object(forKey: "readToMe") {
            print("readtome option: \(readToMe)")
            if readToMe as! Bool{
                print("Read to me")
                ReadToMe.player.pageTwo(storyLabel: story!)
            }
        }
    }
}
