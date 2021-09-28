//
//  YoutubeApiClient.swift
//  TUV
//
//  Created by Khalil Kum on 9/27/21.
//

import Foundation

class YoutubeApiClient {
    static let baseUri = "https://www.googleapis.com/youtube/v3"
    static var apiKey = ""
    static let decoder = JSONDecoder()
    
    enum Endpoints {
        case getChannel(String)
        case getPlaylist(String)
        case getVideo(String)
        case userProfile(String)
        case videoPage(String)
        
        var url: URL {
            return URL(string: urlString)!
        }
        
        
        private var urlString: String {
            switch self {
            case .getChannel(let channelId):
                return baseUri + "/channels?id=\(channelId)&key=\(apiKey)&part=snippet,contentDetails"
            case .getPlaylist(let playlistId):
                return baseUri + "/playlistItems?playlistId=\(playlistId)&key=\(apiKey)&part=snippet,contentDetails"
            case .getVideo(let videoId):
                return baseUri + "/videos?id=\(videoId)&key=\(apiKey)&part=snippet,contentDetails"
            case .userProfile(let channelId):
                return "https://www.youtube.com/channel/\(channelId)"
            case .videoPage(let videoId):
                return "https://www.youtube.com/watch?v=\(videoId)"
            }
        }
    }
    
    class func getChannel(with channelId: String, completionHandler: @escaping ((YoutubeApiSchemas.ChannelsResponse?, Error?) -> Void)) {
        let url = Endpoints.getChannel(channelId).url
        
        taskForGetRequest(url: url, response: YoutubeApiSchemas.ChannelsResponse.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getPlaylist(with playlistId: String, completionHandler: @escaping ((YoutubeApiSchemas.PlaylistsResponse?, Error?) -> Void)) {
        let url = Endpoints.getPlaylist(playlistId).url
        
        taskForGetRequest(url: url, response: YoutubeApiSchemas.PlaylistsResponse.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getVideo(with videoId: String, completionHandler: @escaping ((YoutubeApiSchemas.VideosResponse?, Error?) -> Void)) {
        let url = Endpoints.getVideo(videoId).url
        
        taskForGetRequest(url: url, response: YoutubeApiSchemas.VideosResponse.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode(YoutubeApiSchemas.ApiClientError.self, from: data).error
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, errorResponse)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completionHandler(nil, error)
                    }
                }
            }
        }
        
        task.resume()
    }
}
