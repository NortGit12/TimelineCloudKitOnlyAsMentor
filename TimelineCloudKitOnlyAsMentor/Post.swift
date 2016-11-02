//
//  Post.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit

class Post {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var comments: [Comment]
    var photoData: Data?
    var timestamp: Date
    
    var photo: UIImage? {
        
        guard let photoData = self.photoData else { return nil }
        
        return UIImage(data: photoData)
    }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    init(comments: [Comment] = [], photoData: Data?, timestamp: Date = Date()) {
        
        self.comments = comments
        self.photoData = photoData
        self.timestamp = timestamp
    }
}

// SearchableRecord support

extension Post: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        
        let results = self.comments.map({ $0.matches(searchTerm: searchTerm) })
        
        return results.count > 0 ? true : false
    }
}






















