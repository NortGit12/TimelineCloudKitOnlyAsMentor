//
//  CloudKitSyncable.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 11/3/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
    
    //==================================================
    // MARK: - Initializers
    //==================================================
    
    init?(record: CKRecord)
}

// CloudKit support

extension CloudKitSyncable {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    var cloudKitReference: CKReference? {
        
        guard let cloudKitRecordID = cloudKitRecordID
            else {
            
                NSLog("Error finding the cloudKitRecordID.")
                return nil
        }
        
        let cloudKitReference = CKReference(recordID: cloudKitRecordID, action: .deleteSelf)
        
        return cloudKitReference 
    }
    
    var isSynced: Bool {
        
        return cloudKitRecordID != nil
    }
    
    //==================================================
    // MARK: - Methods
    //==================================================
}






















