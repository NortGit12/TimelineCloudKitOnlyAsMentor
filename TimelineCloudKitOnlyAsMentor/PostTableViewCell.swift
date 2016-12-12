//
//  PostTableViewCell.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 11/1/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//
import UIKit

class PostTableViewCell: UITableViewCell {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    @IBOutlet weak var postImageView: UIImageView!
    
    var post: Post? {
        
        didSet {
            
            updateViews()
        }
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func updateViews() {
        
        postImageView.image = post?.photo
    }
    
}
