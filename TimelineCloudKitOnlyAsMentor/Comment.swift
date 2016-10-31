//
//  Comment.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import Foundation

struct Comment {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var post: Post
    var text: String
    var timestamp: Date
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init(post: Post, text: String, timestamp: Date = Date()) {
        
        self.post = Post
        self.text = text
        self.timestamp = timestamp
    }
}
