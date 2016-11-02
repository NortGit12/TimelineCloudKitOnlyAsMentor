//
//  Comment.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import Foundation

class Comment {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var post: Post?
    var text: String
    var timestamp: Date
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init(post: Post?, text: String, timestamp: Date = Date()) {
        
        self.post = post
        self.text = text
        self.timestamp = timestamp
    }
}

// SearchableRecord support

extension Comment: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        
        return text.contains(searchTerm)
    }
}
