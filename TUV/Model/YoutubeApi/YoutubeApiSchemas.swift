//
//  YoutubeApiSchemas.swift
//  TUV
//
//  Created by Khalil Kum on 9/27/21.
//

import Foundation

class YoutubeApiSchemas {
    struct ChannelsResponse: Decodable {
        let items: [ChannelObject]
        let pageInfo: PageInfo
    }

    struct ChannelObject: Decodable {
        let id: String
        let contentDetails: ChannelContentDetails
    }

    struct ChannelContentDetails: Decodable {
        let relatedPlaylists: RelatedPlaylists
    }

    struct RelatedPlaylists: Decodable {
        let playlistId: String
        
        enum CodingKeys: String, CodingKey {
            case playlistId = "uploads"
        }
    }

    struct PlaylistsResponse: Decodable {
        let items: [PlaylistObject]
        let pageInfo: PageInfo
    }

    struct PlaylistObject: Decodable {
        let snippet: PlaylistSnippet
        let contentDetails: PlaylistContentDetails
    }

    struct PlaylistSnippet: Decodable {
        let channelTitle: String
        let position: Int
        let videoOwnerChannelId: String
    }

    struct PlaylistContentDetails: Decodable {
        let videoId: String
    }

    struct VideosResponse: Decodable {
        let items: [VideoObject]
        let pageInfo: PageInfo
    }

    struct VideoObject: Decodable {
        let id: String
        let snippet: VideoSnippet
    }

    struct VideoSnippet: Decodable {
        let thumbnails: VideoThumbnails
    }

    struct VideoThumbnails: Decodable {
        let high: ThumbnailInfo
    }

    struct ThumbnailInfo: Decodable {
        let url: String
        let width: Int
        let height: Int
    }

    struct PageInfo: Decodable {
        let totalResults: Int
        let resultsPerPage: Int
    }
    
    struct ApiClientError: Decodable {
        let error: ApiClientErrorObject
    }
    
    struct ApiClientErrorObject: Decodable {
        let code: Int
        let message: String
    }
}

extension YoutubeApiSchemas.ApiClientErrorObject: LocalizedError, CustomDebugStringConvertible {
    var debugDescription: String {
        return message
    }
    
    var errorDescription: String? {
        return "code: \(code)\nmessage: \(message)"
    }
    
}
