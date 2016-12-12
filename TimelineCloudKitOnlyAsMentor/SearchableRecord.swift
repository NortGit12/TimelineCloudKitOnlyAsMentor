//
//  SearchableRecord.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 11/2/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//
import Foundation

protocol SearchableRecord {
    
    func matches(searchTerm: String) -> Bool
}
