//
//  ReadToMe.swift
//  PolarAdventure
//
//  Created by Isabel  Lee on 13/04/2017.
//  Copyright © 2017 Isabel  Lee. All rights reserved.
//  Attribution: http://stackoverflow.com/questions/1429571/how-to-stop-nstimer-event

import UIKit

//A singleton that manages playing the read to me sound files, and highlighting text accordingly

class ReadToMe {
    
    static let player = ReadToMe()
    var attributedString = NSMutableAttributedString()
    weak var textLabel: UILabel!
    var pageOneString = NSMutableAttributedString()
    var pageTwoString = NSMutableAttributedString()
    var pageThreeString = NSMutableAttributedString()
    var pageFourString = NSMutableAttributedString()
    var pageFiveString = NSMutableAttributedString()
    var pageSixString = NSMutableAttributedString()
    var pageSevenString = NSMutableAttributedString()
    let blue = UIColor(red: 1/255, green: 64/255, blue: 140/255, alpha: 1)
    var timerList:[Timer] = []
    
    private init(){
        setUP()
    }
    
    
    //MARK: ReadPage functions
    
    //These functions reads and highlights each page
    func pageOne(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page1", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageOneString
        SharedAudioPlayer.player.play(name: "page1")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageTwo(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page2", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageTwoString
        SharedAudioPlayer.player.play(name: "page2")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageThree(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page3", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageThreeString
        SharedAudioPlayer.player.play(name: "page3")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageFour(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page4", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageFourString
        SharedAudioPlayer.player.play(name: "page4")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageFive(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page5", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageFiveString
        SharedAudioPlayer.player.play(name: "page5")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageSix(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page6", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageSixString
        SharedAudioPlayer.player.play(name: "page6")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    func pageSeven(storyLabel: UILabel) {
        let path = Bundle.main.path(forResource: "page7", ofType:"plist")
        let timer = NSArray(contentsOfFile:path!) as! [[String : Any]]
        attributedString = pageSevenString
        SharedAudioPlayer.player.play(name: "page7")
        setTimer(timer: timer)
        textLabel = storyLabel
    }
    
    //MARK: Supporting functions
    
    //Set timer according to the timer array parsed from the plist. 
    //The each element in the timer array be a dictionary, containing a "word" key, 
    //which is the word that should be highlighted, and a "start" key, indicating the time
    //the the word should be highlighted
    
    func setTimer(timer: [[String: Any]]) {
        removeAllTimer()
        var startIndex = 0
        for i in 0..<timer.count{
            let word = timer[i]["word"] as! String
            let time = timer[i]["start"] as! Double
            let length = word.characters.count
            let wordTimer = Timer.scheduledTimer(timeInterval: time, target: self, selector: #selector(updateAttributedString(_:)), userInfo: [startIndex, length], repeats: false)
            timerList.append(wordTimer)
            startIndex += length + 1
        }
    }
    
    //Clear all formatting of the label - storyLabel
    //This takes care of cleaning up any text highlighting.
    func clearFormatting(storyLabel: UILabel) {
        let storyText = storyLabel.attributedText?.string
        let formattedString = formatString(text: storyText!)
        storyLabel.attributedText = formattedString
    }
    
    //Hightlight the correct word according to the range provided in userInfo
    //range is an array of Int with two elements. The first element being the start index, and the 
    //second element being the length of the word that should be highlighted
    @objc func updateAttributedString(_ timer: Timer) {
        let range = timer.userInfo as! [Int]
        
        attributedString.addAttribute(NSBackgroundColorAttributeName,
                                      value: UIColor.clear,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: blue,
                                      range: NSRange(location: 0, length: attributedString.length))
        
        attributedString.addAttribute(NSBackgroundColorAttributeName,
                                      value: blue,
                                      range: NSRange(location: range[0], length: range[1]))
        
        attributedString.addAttribute(NSForegroundColorAttributeName,
                                      value: UIColor.white,
                                      range: NSRange(location: range[0], length: range[1]))
        
        textLabel.attributedText = attributedString
    }
    
    //Removes all timer in case the user turns a page or taps play again before the read to me has finished.
    func removeAllTimer() {
        for timer in timerList {
            timer.invalidate()
        }
        timerList = []
    }
    
    //Format text
    func formatString(text: String) -> NSMutableAttributedString {
        let formattedString = NSMutableAttributedString(string: text,
                                                        attributes: [NSFontAttributeName: UIFont(name: "ChalkboardSE-Regular",
                                                       size: 25.0)!])
        formattedString.addAttribute(NSForegroundColorAttributeName,
                                     value: blue,
                                     range: NSRange(location: 0, length: formattedString.length))
        return formattedString
    }
    
    
    //MARK: SetUp
    
    func setUP() {
        let text1 = "A baby penguin got separated from his family during a severe snowstorm, and was all alone on a tiny iceberg. Everyday, he would walk around on the iceberg, wondering if he should go find his family, but he was too scared to go alone.                 "
        
        pageOneString = formatString(text: text1)
        
        let text2 = "One day, the penguin was standing on the edge of the iceberg, watching some little fish swim by, when he noticed something different. It was a shark!"
        pageTwoString = formatString(text: text2)
        
        let text3 = "Suddenly, the shark hit the iceberg! Poor little penguin was so scared!"
        pageThreeString = formatString(text: text3)
        
        let text4 = "It accidently fell into the water! Oh no! But the shark was very kind, and wanted to help. "
        pageFourString = formatString(text: text4)
        
        let text5 = "The penguin was very thankful that the shark saved him! I'm sorry I scared you, said the shark, I'm nearsighted and I can't see things clearly. "
        pageFiveString = formatString(text: text5)
        
        let text6 = "The penguin told the shark how he lost his family. And the shark decided to help the penguin find his family!"
        pageSixString = formatString(text: text6)
        
        let text7 = "With new friends, they will now set off on a brand new adventure!  "
        pageSevenString = formatString(text: text7)
    }
    

}
