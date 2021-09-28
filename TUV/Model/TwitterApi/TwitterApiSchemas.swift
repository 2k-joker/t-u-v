//
//  TwitterApiSchemas.swift
//  TUV
//
//  Created by Khalil Kum on 9/23/21.
//

import Foundation

class TwitterApiSchemas {
    struct UserResponse: Decodable {
        let userData: UserData
        
        enum CodingKeys: String, CodingKey {
            case userData =  "data"
        }
    }
    
    struct TweetsResponse: Decodable {
        let tweetsData: [TweetData]
        let tweetsMetadata: TweetsMetadata
        
        enum CodingKeys: String, CodingKey {
            case tweetsData =  "data"
            case tweetsMetadata = "meta"
        }
    }

    struct UserData: Decodable {
        let id: String
        let username: String
    }
    
    struct TweetData: Decodable {
        let id: String
        let publicMetrics: TweetPublicMetrics
        let text: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case publicMetrics = "public_metrics"
            case text
        }
    }
    
    struct TweetPublicMetrics: Decodable {
        let retweetCount: Int
        let replyCount: Int
        let likeCount: Int
        let quoteCount: Int
        
        enum CodingKeys: String, CodingKey {
            case retweetCount = "retweet_count"
            case replyCount = "reply_count"
            case likeCount = "like_count"
            case quoteCount = "quote_count"
        }
    }

    struct TweetsMetadata: Decodable {
        let newestId: String
        
        enum CodingKeys: String, CodingKey {
            case newestId = "newest_id"
        }
    }
    
    struct ApiClientError: Decodable {
        let detail: String
        let title: String
    }
}

extension TwitterApiSchemas.ApiClientError: LocalizedError, CustomDebugStringConvertible {
    var debugDescription: String {
        return detail
    }
    
    var errorDescription: String? {
        return "title: \(title)\ndetails: \(detail)"
    }
    
}
