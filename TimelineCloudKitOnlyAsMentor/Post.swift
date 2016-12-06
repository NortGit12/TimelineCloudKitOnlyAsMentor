//
//  Post.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 10/31/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import UIKit
import CloudKit

class Post: CloudKitSyncable {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    static let photoDataKey = "photoData"
    static let recordTypeKey = "recordType"
    static let timestampKey = "timestamp"
    static let typeKey = "Post"
    
    var cloudKitRecordID: CKRecordID?
    var comments: [Comment]
    
    var photo: UIImage? {
        
        guard let photoData = self.photoData else { return nil }
        
        return UIImage(data: photoData)
    }
    
    var photoData: Data?
    var recordType: String { return "Post" }
    var timestamp: Date
        
    fileprivate var temporaryPhotoURL: URL {
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? self.photoData?.write(to: fileURL, options: [.atomic])
        
        return fileURL
    }
    
    let timestampKey = "timestamp"
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    init(comments: [Comment] = [], photoData: Data?, timestamp: Date = Date()) {
        
        self.comments = comments
        self.photoData = photoData
        self.timestamp = timestamp
    }
    
    convenience required init?(record: CKRecord) {
        
        guard let photoAsset = record[Post.photoDataKey] as? CKAsset 
        , let timestamp = record.creationDate
            else {
                
                NSLog("Error unwrapping values from the Post's CloudKit record.")
                return nil
        }
        
        let photoData = try? Data(contentsOf: photoAsset.fileURL)
        
        self.init(photoData: photoData, timestamp: timestamp)
        
        self.cloudKitRecordID = record.recordID
//        self.comments = []
    }
}

// SearchableRecord support

extension Post: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        
        let matchingComments = comments.filter { $0.matches(searchTerm: searchTerm) }
        
        return !matchingComments.isEmpty
    }
}

// CloudKit support

extension CKRecord {
    
    convenience init(_ post: Post) {
        
        let recordID = CKRecordID(recordName: UUID().uuidString)
        
        self.init(recordType: post.recordType, recordID: recordID)
        
        self[Post.photoDataKey] = CKAsset(fileURL: post.temporaryPhotoURL)
        self[Post.timestampKey] = post.timestamp as CKRecordValue?
    }
}





















