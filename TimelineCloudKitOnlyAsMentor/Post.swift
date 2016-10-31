//
//  Post.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit

struct Post {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var comments: [Comment]
    var photoData: Data
    var timestamp: Date
    
    var photo: UIImage {
        
        return UIImage(data: self.photoData)!
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    init(photoData: Data, timestamp: Date = Date(), comments: [Comment] = [Comment]()) {
        
        self.photoData = photoData
        self.timestamp = timestamp
        self.comments = comments
    }
}
