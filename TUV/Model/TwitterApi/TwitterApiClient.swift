//
//  TwitterApiClient.swift
//  TUV
//
//  Created by Khalil Kum on 9/22/21.
//

import Foundation

class TwitterApiClient {
    // MARK: Properties
    static let appBaseUri = "https://twitter.com/_2k_joker/status/1242844482577534977"
    static let baseUri = "https://api.twitter.com/2"
    static var authorization: String = ""
    static let decoder = JSONDecoder()
    
    enum Endpoints {
        case getUser(String)
        case getUserTweets(String)
        case getTweet(String)
        case tweetStatusPage(String, String)
        case userProfile(String)

        var url: URL {
            return URL(string: urlString)!
        }

        private var urlString: String {
            switch self {
            case .getUser(let username):
                return baseUri + "/users/by/username/\(username)"
            case .getUserTweets(let userId):
                return baseUri + "/users/\(userId)/tweets?max_results=5&tweet.fields=public_metrics"
            case .getTweet(let tweetId):
                return baseUri + "/tweets/\(tweetId)?tweet.fields=public_metrics"
            case .tweetStatusPage(let username, let tweetId):
                return "https://twitter.com/\(username)/status/\(tweetId)"
            case .userProfile(let username):
                return "https://twitter.com/\(username)"
            }
        }
    }

    class func getUser(username: String, completionHandler: @escaping (TwitterApiSchemas.UserData?, Error?) -> Void) {
        let url = Endpoints.getUser(username).url
        
        taskForGetRequest(url: url, response: TwitterApiSchemas.UserResponse.self) { response, error in
            if let response = response {
                completionHandler(response.userData, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getUserTweets(userId: String, completionHandler: @escaping (TwitterApiSchemas.TweetsResponse?, Error?) -> Void) {
        let url = Endpoints.getUserTweets(userId).url

        taskForGetRequest(url: url, response: TwitterApiSchemas.TweetsResponse.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getTweet(tweetId: String, completionHandler: @escaping (TwitterApiSchemas.TweetData?, Error?) -> Void) {
        let url = TwitterApiClient.Endpoints.getTweet(tweetId).url
        
        taskForGetRequest(url: url, response: TwitterApiSchemas.TweetData.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        var apiRequest = URLRequest(url: url)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(authorization, forHTTPHeaderField: "Authorization")
    
        let task = URLSession.shared.dataTask(with: apiRequest) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            debugPrint(String(data: data, encoding: .utf8)!)
            
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                do {
                    let errorResponse = try decoder.decode([String: [TwitterApiSchemas.ApiClientError]].self, from: data)
                    let userNotFoundError = errorResponse.values.first?.first
                    
                    DispatchQueue.main.async {
                        completionHandler(nil, userNotFoundError)
                    }
                } catch {
                    do {
                        let errorResponse = try decoder.decode(TwitterApiSchemas.ApiClientError.self, from: data)
                        
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
        }
        
        task.resume()
    }
}
