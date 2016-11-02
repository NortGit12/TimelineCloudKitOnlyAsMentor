//
//  AddPostTableViewController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, PhotoSelectViewControllerDelegate {
    
    //==================================================
    // MARK: - _Properties
    //==================================================
    
    @IBOutlet weak var captionTextField: UITextField!
    var image: UIImage?
    var photoSelectViewController: PhotoSelectViewController?
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func addPostButtonTapped(_ sender: UIButton) {
        
        guard let image = self.image
            , let caption = captionTextField.text
            , caption.characters.count > 0 else {
                
                let missingRequiredInfoAlertController = UIAlertController(title: "Missing Info", message: "The image and caption are required for a post.  Make sure they are both present and try again.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                
                missingRequiredInfoAlertController.addAction(okAction)
                
                present(missingRequiredInfoAlertController, animated: true, completion: nil)
                
                return
        }
        
        PostController.shared.createPost(withImage: image, andCaption: caption) { _ in 
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //==================================================
    // MARK: - Navigation
    //==================================================
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPhotoSelectEmbedSegue" {
            
            let embeddedViewController = segue.destination as? PhotoSelectViewController
            embeddedViewController?.delegate = self
        }
    }
    
    //==================================================
    // MARK: - PhotoSelectViewControllerDelegate
    //==================================================
    
    func selected(image: UIImage) {
        
        self.image = image
    }
}























