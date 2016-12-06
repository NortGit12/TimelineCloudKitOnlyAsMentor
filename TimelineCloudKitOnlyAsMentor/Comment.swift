//
//  Comment.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import Foundation
import CloudKit

class Comment: CloudKitSyncable {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    static let postReferenceKey = "postReference"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let typeKey = "Comment"
    
    var cloudKitRecordID: CKRecordID?
    var post: Post?
    var recordType: String { return Comment.typeKey }
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
    
    convenience required init?(record: CKRecord) {
        
        guard let text = record[Comment.textKey] as? String
            , let timestamp = record.creationDate
        else {
            
            NSLog("Error unwrapping values from the Comment's CloudKit record.")
            return nil
        }
        
        self.init(post: nil, text: text, timestamp: timestamp)
        
        self.cloudKitRecordID = record.recordID
    }
}

// SearchableRecord support

extension Comment: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        
        return text.lowercased().contains(searchTerm.lowercased())
    }
}

// CloudKit support

extension CKRecord {
    
    convenience init(_ comment: Comment) {
        
        guard let post = comment.post else { fatalError("Comment does not have a Post relationship") }
        
        let commentRecordID = CKRecordID(recordName: UUID().uuidString)
        let postRecordID = post.cloudKitRecordID ?? CKRecord(post).recordID
        
        self.init(recordType: comment.recordType, recordID: commentRecordID)
        
        self[Comment.postReferenceKey] = CKReference(recordID: postRecordID, action: .deleteSelf)
        self[Comment.textKey] = comment.text as CKRecordValue?
        self[Comment.timestampKey] = comment.timestamp as CKRecordValue?
    }
}
























