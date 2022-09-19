//
//  DateManager.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/13.
//

import Foundation

class DateManager {
    
    static let shared: DateManager = DateManager()
    
    private init() {}
    
    func stringToDate(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        guard let date = dateFormatter.date(from: dateStr) else { return Date() }
        return date
    }
    
    func string14ToDate(dateStr: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        guard let date = dateFormatter.date(from: dateStr) else { return Date() }
        return date
    }
    
    func getDateTime() -> String {
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        let dateString = df.string(from: date)
        return dateString
    }
    
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringGetDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringGetTime(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringGetHour(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringGetMin(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToString14Start(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd000000"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToString14End(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd240000"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringDateOnly(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func dateToStringWithoutSecond(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let string = dateFormatter.string(from: date)
        return string
    }
    
    func stringDateToString14(dateStr: String) -> String {
        
        let originDateFormatter = DateFormatter()
        originDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date = originDateFormatter.date(from: dateStr) else { return "fail" }
        
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "yyyyMMddHHmmss"
        let targetString = targetDateFormatter.string(from: date)
        
        return targetString
    }
    
    func stringDateToString14p2(dateStr: String) -> String {
        
        let originDateFormatter = DateFormatter()
        originDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        guard let date = originDateFormatter.date(from: dateStr) else { return "" }
        
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "yyyyMMddHHmmss"
        let targetString = targetDateFormatter.string(from: date)
        
        return targetString
    }

    
    func string14ToStringDate(dateStr: String) -> String {
        
        if dateStr == "" {
            return ""
        }
        
        let originDateFormatter = DateFormatter()
        originDateFormatter.dateFormat = "yyyyMMddHHmmss"
        guard let date = originDateFormatter.date(from: dateStr) else { return "fail" }
        
        let targetDateFormatter = DateFormatter()
        targetDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let targetString = targetDateFormatter.string(from: date)
        
        return targetString
    }
    
    func string14ToStringDatep2(dateStr: String, withSecond: Bool) -> String {
        
        if dateStr == "" {
            return ""
        }
        
        let originDateFormatter = DateFormatter()
        originDateFormatter.dateFormat = "yyyyMMddHHmmss"
        guard let date = originDateFormatter.date(from: dateStr) else { return "fail" }
        
        if withSecond {
            let targetDateFormatter = DateFormatter()
            targetDateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
            let targetString = targetDateFormatter.string(from: date)
            return targetString
        } else {
            let targetDateFormatter = DateFormatter()
            targetDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let targetString = targetDateFormatter.string(from: date)
            return targetString
        }
    }
    
}

