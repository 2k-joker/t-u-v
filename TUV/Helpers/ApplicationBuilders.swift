//
//  ApplicationBuilders.swift
//  TUV
//
//  Created by Khalil Kum on 9/25/21.
//

import UIKit

class ApplicationBuilders {
    class func buildAppUrl(for appType: Constants.AppType, with appData: [String: Any], context: Constants.AppUrlContext) -> URL {
        switch appType {
        case .twitter:
            let username = appData["appUsername"] as? String ?? ""
            
            if context == .specificContent {
                let tweetId = appData["latestTweetId"] as? String ?? ""

                return TwitterApiClient.Endpoints.tweetStatusPage(username, tweetId).url
            } else {
                return TwitterApiClient.Endpoints.userProfile(username).url
            }
        case .youtube:
            if context == .specificContent {
                let videoId = appData["latestVideoId"] as? String ?? ""
                return YoutubeApiClient.Endpoints.videoPage(videoId).url
            } else {
                let channelId = appData["channelId"] as? String ?? ""
                return YoutubeApiClient.Endpoints.userProfile(channelId).url
            }
        default:
            return URL(string: "http://www.example.com")!
        }
    }
    
    class func buildPageControl(withNumberOfPages pageCount: Int) -> UIPageControl {
        let pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 60, width: UIScreen.main.bounds.width, height: 50))
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.white
        pageControl.pageIndicatorTintColor = .lightGray
        pageControl.currentPageIndicatorTintColor = .white
        
        return pageControl
    }
}
