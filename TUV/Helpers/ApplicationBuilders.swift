//
//  ApplicationBuilders.swift
//  TUV
//
//  Created by Khalil Kum on 9/25/21.
//

import Foundation

class ApplicationBuilders {
    func buildAppInfoObject(for appName: String, with appInfo: [String: Any]) -> [String:Any] {
        let connectedAppType = Constants.AppType.init(rawValue: appName)
//        var baseAppInfo: [String: Any] = [ "imageName": connectedAppType?.imageName, "username": ]

        switch connectedAppType {
        case .instagram:
            return [:]
        case .twitter:
            return [:]
        case .youtube:
            return [:]
        default:
            return [:]
        }
    }
}
