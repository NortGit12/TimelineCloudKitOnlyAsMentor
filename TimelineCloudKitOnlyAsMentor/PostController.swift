//
//  PostController.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    let cloudKitManager: CloudKitManager
    var comments: [Comment] = posts.flatMap({ $0.comments })
    var posts = [Post]()
    static let shared = PostController()
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init() {
        
        self.cloudKitManager = CloudKitManager()
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    @discardableResult func addComment(toPost post: Post
                            , commentText text: String
                            , completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        
        let comment = Comment(post: post, text: text)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment), completion: { (record, error) in
            
            guard let record = record else {
                
                if let error = error {
                    
                    NSLog("Error saving new comment to CloudKit: \(error.localizedDescription)")
                    return
                }
            }
            
            comment.cloudKitRecordID = record.recordID
            
            completion(comment)
        })
        
        return comment
    }
    
    func createPost(withImage image: UIImage, andCaption caption: String, completion: @escaping ((Post) -> Void) = { _ in }) {
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            
            NSLog("Error converting the post's image to data.")
            return
        }
        
        let post = Post(photoData: imageData)
        posts.append(post)
        
        let postRecord = CKRecord(post)
        
        cloudKitManager.saveRecord(postRecord, completion: { (record, error) in
            
            guard let record = record else {
                
                
                if let error = error {
                    
                    NSLog("Error saving new post to CloudKit: \(error.localizedDescription)")
                    return
                }
                
                completion(post)
                return
            }
            
            post.cloudKitRecordID = record.recordID
            
            // Save the comment
            
            let comment = Comment(post: post, text: caption)
            let commentRecord = CKRecord(comment)
            
            self.cloudKitManager.saveRecord(commentRecord, completion: { (record, error) in
                
                guard let record = record else {
                    
                    if let error = error {
                        
                        NSLog("Error saving new comment to CloudKit: \(error.localizedDescription)")
                        return
                    }
                }
                
                comment.cloudKitRecordID = record.recordID
                
                completion(post)
            })
        })
        
    }
    
    func fetchNewRecords(type: String, completion: @escaping (() -> Void) = { _ in }) {
        
        let referencesToExclude: [CKReference] = self.syncedRecords(type: type).flatMap({ $0.cloudKitReference })
        
        var predicate: NSPredicate
        if referencesToExclude.isEmpty {
            predicate = NSPredicate(value: true)
        } else {
            predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [referencesToExclude])
        }
        
        cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
        
            switch type {
                
            case Post.typeKey:
                
                if let post = Post(record: record) {
                    
                    self.posts.append(post)
                }
                
            case Comment.typeKey:
                
                guard let postReference = record[Comment.postReferenceKey] as? CKReference
                    , let postIndex = self.posts.index(where: { $0.cloudKitRecordID == postReference.recordID })
                    , let comment = Comment(record: record) else { return }
                
                let post = self.posts[postIndex]
                post.comments.append(comment)
                comment.post = post
                
            default:
                return
            }
        }) { (records, error) in
            
            if let error = error {
                
                NSLog("Error fetching \(type) records: \(error.localizedDescription)")
            }
            
            completion()
        }
    }
    
    private func recordsOf(type: String) -> [CloudKitSyncable] {
    
        switch type {
            
        case "Post":
            return posts.flatMap({ $0 as CloudKitSyncable })
        case "Comment":
            return comments.flatMap({ $0 as CloudKitSyncable })
        default:
            return []
        }
    }
    
    func syncedRecords(type: String) -> [CloudKitSyncable] {
        
        return recordsOf(type: type).filter { $0.isSynced }
    }
    
    func unsyncedRecords(type: String) -> [CloudKitSyncable] {
        
        return recordsOf(type: type).filter { !$0.isSynced }
    }
}
























