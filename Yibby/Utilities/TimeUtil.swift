//
//  TimeUtil.swift
//  Yibby
//
//  Created by Kishy Kumar on 7/23/16.
//  Copyright © 2016 Yibby. All rights reserved.
//


open class TimeUtil {

    static func diffFromCurTimeISO (_ fromIsoTime: String) -> TimeInterval {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        
        let isoNSDate: Date = formatter.date(from: fromIsoTime)!
        
        // Get the current time
        let curTime = Date()
        
        let secondsBetween: TimeInterval = curTime.timeIntervalSince(isoNSDate)
        return secondsBetween
    }

    static func diffFromCurTime (_ fromTime: Date) -> TimeInterval {
        
        // Get the current time
        let curTime = Date()
        
        let secondsBetween: TimeInterval = curTime.timeIntervalSince(fromTime)
        return secondsBetween
    }
}
