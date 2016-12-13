//
//  TemporaryCache.swift
//  Ello
//
//  Created by Colin Gray on 6/1/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

typealias TemporaryCacheEntry = (image: UIImage, expiration: Date)
public enum CacheKey {
    case coverImage
    case profilePicture
}
public struct TemporaryCache {
    static var coverImage: TemporaryCacheEntry?
    static var profilePicture: TemporaryCacheEntry?

    static func save(_ key: CacheKey, image: UIImage) {
        let fiveMinutes: TimeInterval = 5 * 60
        let date = Date(timeIntervalSinceNow: fiveMinutes)
        switch key {
        case .coverImage:
            TemporaryCache.coverImage = (image: image, expiration: date)
        case .profilePicture:
            TemporaryCache.profilePicture = (image: image, expiration: date)
        }
    }

    static func load(_ key: CacheKey) -> UIImage? {
        let date = Date()
        let entry: TemporaryCacheEntry?

        switch key {
        case .coverImage:
            entry = TemporaryCache.coverImage
        case .profilePicture:
            entry = TemporaryCache.profilePicture
        }

        if let entry = entry, (entry.expiration as NSDate).earlierDate(date) == date {
            return entry.image
        }
        return nil
    }
}
