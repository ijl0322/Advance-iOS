//
//  PageOneViewController.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 05/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Attribution: http://stackoverflow.com/questions/990221/multiple-lines-of-text-in-uilabel

import UIKit

class PageOneViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var screenWidth = Size.shared.screenWidth
    var screenHeight = Size.shared.screenHeight
    var storyLineLength = 0.0
    var storyLineXPosition = 0.0
    var storyLineYPosition = 0.0
    var story: UILabel?
    var penguin: Penguin?
    let fishView = FishView()
    let narwhale = Narwhale()
    var playButton: UIButton?
    
    @IBAction func walkRight(_ sender: UIButton) {
        penguin!.walkRight()
    }
    
    @IBAction func walk(_ sender: UIButton) {
        penguin!.walkLeft()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton = UIButton(frame: CGRect(x: 100, y: 10, width: 80, height: 80))
        playButton?.setImage(UIImage(named: "soundButton"), for: .normal)
        playButton?.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(playButton!)
        
        penguin = Penguin(x: screenWidth * 0.4, y: screenHeight * 0.35)
        storyLineLength = screenWidth*0.8
        storyLineXPosition = screenWidth*0.1
        storyLineYPosition = screenHeight*0.1
        story = UILabel(frame: CGRect(x: storyLineXPosition, y: storyLineYPosition, width: storyLineLength, height: 150))
        story?.attributedText = ReadToMe.player.pageOneString
        story?.lineBreakMode = .byWordWrapping
        story?.numberOfLines = 0
        story?.sizeToFit()
        
        addEasterEgg()
        narwhale.alpha = 0
        
        self.view.addSubview(fishView)
        self.view.addSubview(story!)
        self.view.addSubview(penguin!)
        self.view.addSubview(narwhale)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fishView.toStartPosition()
        penguin?.toStartPosition()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        UserDefaults.standard.set(0, forKey: "bookmark")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.fishView.startSwim()
            self.isReadToMeOn()
            if Random.generator.shouldShowNarwhale() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    self.narwhale.startSwim()
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        ReadToMe.player.removeAllTimer()
        SharedAudioPlayer.player.stopAllPlayer()
        ReadToMe.player.clearFormatting(storyLabel: story!)
    }
    
    //Add the gesture recognizer for the easter egg. (A narwhale showing up when the ocean is tapped three times)
    func addEasterEgg() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(fishViewTapped(_:)))
        tapGestureRecognizer.delegate = self
        tapGestureRecognizer.numberOfTapsRequired = 3
        fishView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    //When the ocean is tapped three times, start the narwhale's swimming animation
    func fishViewTapped(_ recognizer: UITapGestureRecognizer) {
        narwhale.startSwim()
    }
    
    func playButtonTapped(_ button: UIButton){
        print("play sound")
        ReadToMe.player.pageOne(storyLabel: story!)
    }
    
    func isReadToMeOn() {
        if let readToMe = UserDefaults.standard.object(forKey: "readToMe") {
            print("readtome option: \(readToMe)")
            if readToMe as! Bool{
                print("Read to me")
                ReadToMe.player.pageOne(storyLabel: story!)
            }
        }
    }
}
