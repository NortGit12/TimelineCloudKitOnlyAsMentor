//
//  PhotoSelectViewController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 11/2/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//
import UIKit

protocol PhotoSelectViewControllerDelegate: class {
    
    func selected(image: UIImage)
}

class PhotoSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    weak var delegate: PhotoSelectViewControllerDelegate?
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    //==================================================
    // MARK: - General
    //==================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //==================================================
    // MARK: - Actions
    //==================================================
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let photoAlertController = UIAlertController(title: "Select Image Source", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        photoAlertController.addAction(cancelAction)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
                
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            photoAlertController.addAction(cameraAction)
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
                
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }
            
            photoAlertController.addAction(photoLibraryAction)
        }
        
        present(photoAlertController, animated: true, completion: nil)
    }
    
    //==================================================
    // MARK: - UIImagePickerControllerDelegate
    //==================================================
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            delegate?.selected(image: image)
            selectImageButton.setTitle("", for: .normal)
            postImageView.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }
}
