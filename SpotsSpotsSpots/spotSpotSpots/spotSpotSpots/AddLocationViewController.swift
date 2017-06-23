//
//  AddLocationViewController.swift
//  spotSpotSpots
//
//  Created by Isabel  Lee on 06/05/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import Photos

class AddLocationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var currentLocation: CLLocation?
    var comment = ""
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var locationImageView: UIImageView!
    
    //Presents a UIImagePickerController to allow the user to add a photo for their new location
    @IBAction func addPhoto(_ sender: UIButton) {
        print("photo picker launched")
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        if self.checkPhotoLibraryAuthorization(){
            print("photo library access granted")
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true){
                
            }
        } else {
            print("photo library access not granted")
            self.pleaseGrantAccessAlert(accessType: "photo library")
        }
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        ClouldKitManager.sharedInstance.addLocation(comment: comment, location: currentLocation!, image: locationImageView.image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextField.delegate = self
    }
    
    //Check if the user has granted photo library access, return true if yes, else return false
    func checkPhotoLibraryAuthorization() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied: return false
        case .authorized: return true
        case .restricted: return false
            
        case .notDetermined:
            var requestFinish = false
            var status = false
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                
                if (newStatus == PHAuthorizationStatus.authorized) {
                    print("Granted access to photo Library")
                    requestFinish = true
                    status = true
                }
                else {
                    print("Denied access to photo Library")
                    requestFinish = true
                }
            })
            
            while (requestFinish == false) {
                
            }
            return status
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            self.locationImageView.image = pickedImage
            
        } else {
            print("Error adding image")
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Present an alert view controller to ask user to grant access to camera or photo library.
    func pleaseGrantAccessAlert(accessType: String){
        let alert = UIAlertController(title: "Please grant access", message: "Benny cam need to access your \(accessType) to put cute bunnies on your photo!", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            UIApplication.shared.open(NSURL(string:UIApplicationOpenSettingsURLString)! as URL, options: [:], completionHandler: nil)
        }))
        
        present(alert, animated: true, completion: nil)
    }

}

extension AddLocationViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if let text = textField.text {
            print("Text Entered: \(text)")
            comment = text
        }
        return
    }
}

