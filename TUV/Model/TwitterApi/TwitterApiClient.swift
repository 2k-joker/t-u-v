//
//  TwitterApiClient.swift
//  TUV
//
//  Created by Khalil Kum on 9/22/21.
//

import Foundation

class TwitterApiClient {
    // MARK: Properties
    static let baseUri = "https://api.twitter.com/2"
    static var authorization: String = ""
    
    enum Endpoints {
        case getUser(String)
        case getUserTweets(String)
        case getTweet(String)

        var url: URL {
            return URL(string: urlString)!
        }

        private var urlString: String {
            switch self {
            case .getUser(let username):
                return TwitterApiClient.baseUri + "/users/by/username/\(username)"
            case .getUserTweets(let userId):
                return TwitterApiClient.baseUri + "/users/\(userId)/tweets?max_results=5&tweet.fields=public_metrics"
            case .getTweet(let tweetId):
                return TwitterApiClient.baseUri + "/tweets/\(tweetId)?tweet.fields=public_metrics"
            }
        }
    }

    class func getUser(username: String, completionHandler: @escaping (TwitterApiSchemas.UserData?, Error?) -> Void) {
        var apiRequest = URLRequest(url: TwitterApiClient.Endpoints.getUser(username).url)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(TwitterApiClient.authorization, forHTTPHeaderField: "Authorization")
        
        taskForGetRequest(request: apiRequest, response: TwitterApiSchemas.UserResponse.self) { response, error in
            if let response = response {
                completionHandler(response.userData, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getUserTweets(userId: String, completionHandler: @escaping (TwitterApiSchemas.TweetsResponse?, Error?) -> Void) {
        var apiRequest = URLRequest(url: TwitterApiClient.Endpoints.getUserTweets(userId).url)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(TwitterApiClient.authorization, forHTTPHeaderField: "Authorization")
        
        taskForGetRequest(request: apiRequest, response: TwitterApiSchemas.TweetsResponse.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func getTweet(tweetId: String, completionHandler: @escaping (TwitterApiSchemas.TweetData?, Error?) -> Void) {
        var apiRequest = URLRequest(url: TwitterApiClient.Endpoints.getTweet(tweetId).url)
        apiRequest.httpMethod = "GET"
        apiRequest.addValue(TwitterApiClient.authorization, forHTTPHeaderField: "Authorization")
        
        taskForGetRequest(request: apiRequest, response: TwitterApiSchemas.TweetData.self) { response, error in
            if let response = response {
                completionHandler(response, nil)
            } else {
                completionHandler(nil, error)
            }
        }
    }
    
    class func taskForGetRequest<ResponseType: Decodable>(request: URLRequest, response: ResponseType.Type, completionHandler: @escaping (ResponseType?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()

            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                
                DispatchQueue.main.async {
                    completionHandler(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }
        
        task.resume()
    }
}
