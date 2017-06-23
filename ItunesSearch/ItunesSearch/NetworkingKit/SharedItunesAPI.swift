//
//  SharedItunesAPI.swift
//  ItunesSearch
//
//  Created by Isabel  Lee on 19/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case CantLoadData
}

//A Networking Singleton that handles all networking tasks in the app
public class SharedItunesApi {
    
    
    //MARK: Variable
    public static let sharedInstance = SharedItunesApi()
    private init() {}
    let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default)
    var dataTask: URLSessionDataTask?
    let session = URLSession.shared

    //Search the itunes store using the searchTerm.
    //Returns an array of dictionary containing all information needed for apps related to the searchTerm provided
    public func search(searchTerm: String, completion: @escaping (([[String:Any]], Error?)->Void)) {
        let keywords = searchTerm.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "https://itunes.apple.com/search?entity=software&term=\(keywords)")
        var resultList: [[String:Any]] = []
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], NetworkError.CantLoadData)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    
                    guard let data = data else {
                        completion([], NetworkError.CantLoadData)
                        return
                    }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let apps = json["results"] as? [[String: Any]] {
                            for app in apps {
                                resultList.append(self.getData(appInfo: app))
                            }
                            
                            completion(resultList, nil)
                        }
                    } catch {
                        print("Error deserializing JSON: \(error)")
                        completion([], NetworkError.CantLoadData)
                    }
                }
            }
        })
        
        dataTask?.resume()
    }
    
    //Retrieve data from the appInfo dictionary that we received from parsing JSON. 
    //Returns a dictionary of information needed.
    func getData(appInfo: [String:Any]) -> [String:Any] {
        var infoList: [String:Any] = [:]
        let keys = ["trackName", "description", "artistName", "artworkUrl100", "screenshotUrls", "trackId", "formattedPrice"]
        for key in keys {
            if let value = appInfo[key] {
                infoList[key] = value
            } else {
                infoList[key] = " "
            }
        }
        
        if let value = appInfo["averageUserRating"] {
                infoList["averageUserRating"] = String(describing: value)
        } else {
            infoList["averageUserRating"] = "No Ratings"
        }
        return infoList
    }
    
    //Query the itunes api using an app's id, and return the information needed in an array of dictionary.
    public func lookUpAppBy(id: String, completion: @escaping (([[String:Any]], Error?)->Void)) {
        
        let url = URL(string: "https://itunes.apple.com/lookup?id=\(id)")
        var resultList: [[String:Any]] = []
        dataTask = defaultSession.dataTask(with: url!, completionHandler: {
            data, response, error in
            if let error = error {
                print(error.localizedDescription)
                completion([], NetworkError.CantLoadData)
            } else if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    guard let data = data else {
                        completion([], NetworkError.CantLoadData)
                        return
                    }
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let apps = json["results"] as? [[String: Any]] {
                            for app in apps {
                                resultList.append(self.getData(appInfo: app))
                            }
                            completion(resultList, nil)
                        }
                    } catch {
                        print("Error deserializing JSON: \(error)")
                        completion([], NetworkError.CantLoadData)
                    }
                }
            }
        })
        dataTask?.resume()
    }
    
    //Retriving the app id from the shortened url received from the Share extension
    public func getAppIdFromUrl(url: URL, completion: @escaping ((String)->Void)) {

        let task = session.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            print("\n\n\n\n\n\n")
            let url = response?.url?.absoluteURL.pathComponents
            if let id = url?.last {
                print("App store id: \(id)")
                let c = id.characters
                let range = c.index(c.startIndex, offsetBy: 2)..<c.index(c.endIndex, offsetBy: 0)
                print("Parsed id: \(id[range])")
                completion(id[range])
            }
        })
        task.resume()
    }
    
    //Download a image from the image URL provided. If it is not successful, returns a placeholder image with
    //A question mark on it.
    public func downloadPhoto(imgUrl: String, completion: @escaping ((UIImage?)->Void)){
        
        let urlString = imgUrl
        guard let url = NSURL(string: urlString) else {
            print("Cannot create NSURL")
            completion(UIImage(named: "none"))
            return
        }
        
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                completion(UIImage(named: "none"))
                return
            }
            let image = UIImage(data: data!)
            print("img downloaded from url")
            completion(image)
        })
        
        task.resume()
    }
}
