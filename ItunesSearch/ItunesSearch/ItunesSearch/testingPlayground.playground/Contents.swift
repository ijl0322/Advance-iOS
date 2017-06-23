//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .none

var dateString:String = "2014-05-20";
var dateFmt = DateFormatter()
// the format you want
dateFmt.dateFormat = "yyyy-MM-dd"
var date1:NSDate = dateFmt.date(from: dateString)! as NSDate;

let url = "com.isabeljlee.itunesSearch://appId=808176012"
let char = "com.isabeljlee.itunesSearch://appId=808176012".characters
let range = char.index(char.startIndex, offsetBy: 36)..<char.index(char.endIndex, offsetBy: 0)
print("Parsed id: \(url[range])")