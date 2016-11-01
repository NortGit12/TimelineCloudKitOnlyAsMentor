//
//  PostController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit

class PostController {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var posts = [Post]()
    static let shared = PostController()
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init() {
        
        
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    func addComment(toPost post: Post, commentText text: String, completion: @escaping (() -> Void) = { _ in }) {
        
        let comment = Comment(post: post, text: text)
        post.comments.append(comment)
        
        completion()
    }
    
    func createPost(withImage image: UIImage, andCaption caption: String, completion: @escaping (() -> Void) = { _ in }) {
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            
            NSLog("Error converting the post's image to data.")
            return
        }
        
        let post = Post(photoData: imageData)
        posts.append(post)
        let comment = addComment(toPost: post, commentText: caption) { _ in
        
            completion()
        }
        
    }
}
























