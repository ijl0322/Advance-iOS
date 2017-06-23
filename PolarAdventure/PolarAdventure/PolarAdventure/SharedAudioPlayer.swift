//
//  SharedAudioPlayer.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 06/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//

import AVFoundation

//Defines a singleton with two audio player shared by every page of the book.
//There is a audio player for the story lines and one for the sound effects, 
//so when the user plays both at the same time, they will not interfere with each other.

class SharedAudioPlayer {
    
    //MARK: Variables
    static let player = SharedAudioPlayer()
    var audioFile: AVAudioPlayer!
    var soundEffect: AVAudioPlayer!
    
    //MARK: Initializer
    private init() {}
    
    //This is the audio player for playing the story
    func play(name: String) {
        let audioFileURL = URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "mp3")!)
        
        do {
            try audioFile = AVAudioPlayer(contentsOf: audioFileURL as URL, fileTypeHint: nil)
            audioFile.prepareToPlay()
        } catch let err as NSError {
            print(err.debugDescription)
        }
        audioFile.play()
    }
    
    //This is the audio player for playing the sound effect
    func playEffect(name: String) {
        let audioFileURL = URL(fileURLWithPath: Bundle.main.path(forResource: name, ofType: "mp3")!)
        
        do {
            try soundEffect = AVAudioPlayer(contentsOf: audioFileURL as URL, fileTypeHint: nil)
            soundEffect.prepareToPlay()
        } catch let err as NSError {
            print(err.debugDescription)
        }
        soundEffect.play()
    }
    
    //Stops all audio player if they are currently playing
    //Used when a user turns a page before a file is done playing
    func stopAllPlayer() {
        if let soundEffect = soundEffect {
            soundEffect.stop()
        }
        if let audioFile = audioFile {
            audioFile.stop()
        }
    }
}

