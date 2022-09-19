//
//  Event.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/15.
//

import Foundation

struct Event: Identifiable {
    
    var id = UUID()
    var eventTitle: String = ""
    var eventDescription: String = ""
    var eventCategory: String = ""
    var eventColorCode: String = ""
    var eventDateFrom: Date = Date()
    var eventDateTo: Date = Date()
    var isCompleted: Bool = false

}
