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
    var comments: [Comment] {
        
        return posts.flatMap({ $0.comments })
    }
    var isSyncing: Bool = false
    var posts = [Post]() {
        didSet {
            
            DispatchQueue.main.async {
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.post(name: PostController.PostsChangedNotification, object: self)
            }
        }
    }
    static let shared = PostController()
    var sortedPosts: [Post] {
        
        return posts.sorted { return $0.timestamp.compare($1.timestamp as Date) == .orderedAscending }
    }
    
    //==================================================
    // MARK: - Initializer
    //==================================================
    
    init() {
        
        self.cloudKitManager = CloudKitManager()
        
        performFullSync()
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
    
    @discardableResult func addComment(toPost post: Post
                            , commentText text: String
                            , completion: @escaping ((Comment) -> Void) = { _ in }) -> Comment {
        
        let comment = Comment(post: post, text: text)
        post.comments.append(comment)
        
        cloudKitManager.saveRecord(CKRecord(comment)) { (record, error) in
            
            if let error = error {
                
                NSLog("Error saving new comment to CloudKit: \(error.localizedDescription)")
                return
            }
            
            comment.cloudKitRecordID = record?.recordID
            
            completion(comment)
        }
        
        DispatchQueue.main.async {
            
            let notificationCenter = NotificationCenter.default
            notificationCenter.post(name: PostController.PostCommentsChangedNotification, object: self)
        }
        
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
    
    func performFullSync(completion: @escaping () -> Void? = { _ in }) {
        
        guard !isSyncing else {
            
            completion()
            return
        }
        
        isSyncing = true
        
        pushChangesToCloudKit { (success, error) in
            
            self.fetchNewRecords(type: Post.typeKey, completion: { 
                
                self.fetchNewRecords(type: Comment.typeKey, completion: {
                    
                    self.isSyncing = false
                    
                    completion()
                })
            }) 
        }
    }
    
    func pushChangesToCloudKit(completion: @escaping ((_ success: Bool, _ error: NSError?) -> Void) = { _, _ in }) {
        
        let unsavedPosts = unsyncedRecords(type: Post.typeKey) as? [Post] ?? []
        let unsavedComments = unsyncedRecords(type: Comment.typeKey) as? [Comment] ?? []
        var unsavedObjectsByRecord = [CKRecord : CloudKitSyncable]()
        
        for post in unsavedPosts {
            
            let record = CKRecord(post)
            unsavedObjectsByRecord[record] = post
        }
        
        for comment in unsavedComments {
            
            let record = CKRecord(comment)
            unsavedObjectsByRecord[record] = comment
        }
        
        let unsavedRecords = Array(unsavedObjectsByRecord.keys)
        
        cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            unsavedObjectsByRecord[record]?.cloudKitRecordID = record.recordID
            
        }) { (records, error) in
            
            let success = records != nil
            completion(success, error as NSError?)
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

extension PostController {
    
    static let PostsChangedNotification = Notification.Name("PostsChangedNotification")
    static let PostCommentsChangedNotification = Notification.Name("PostCommentsChangedNotification")
}
























