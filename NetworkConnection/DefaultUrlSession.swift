//
//  AppConfigurationSetting.swift
//  Umoe
//
//  Created by Manjit on 14/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//

import UIKit

class DefaultUrlSession {
    var urlSession: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        let urlSession = URLSession(configuration: configuration)
        return urlSession
    }

    static let sharedInstance = DefaultUrlSession()
}
