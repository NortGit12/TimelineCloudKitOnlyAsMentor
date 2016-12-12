
//
//  DateHelper.swift
//  TimelineCloudKitOnlyAsMentor
//
//  Created by Jeff Norton on 11/1/16.
//  Copyright © 2016 JeffCryst. All rights reserved.
//
import Foundation

class DateHelper {
    
    //==================================================
    // MARK: - Properties
    //==================================================
    
    let dateFormatter: DateFormatter = {
        
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        return dateFormatter
    }()
}
