//
//  TimeUtil.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/23/16.
//  Copyright © 2016 Yibby. All rights reserved.
//


open class TimeUtil {

    static func diffFromCurTimeISO (_ isoTime: String) -> TimeInterval? {
        
        if let isoNSDate = getDateFromISOTime(isoTime) {
            // Get the current time
            let curTime = Date()
            
            let secondsBetween: TimeInterval = curTime.timeIntervalSince(isoNSDate)
            return secondsBetween
        }
        return nil
    }

    static func diffFromCurTime (_ fromTime: Date) -> TimeInterval {
        
        // Get the current time
        let curTime = Date()
        
        let secondsBetween: TimeInterval = curTime.timeIntervalSince(fromTime)
        return secondsBetween
    }
    
    static func getDateFromISOTime (_ isoTime: String) -> Date? {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        
        return formatter.date(from: isoTime)
    }
    
    static func prettyPrintDate1 (_ date: Date) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
    }
}
