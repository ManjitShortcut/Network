//
//  AppConfigurationSetting.swift
//  Umoe
//
//  Created by Manjit on 13/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//

import Foundation

typealias NetWorkWebserviceResponseBlock = (_ httpsResponse: HTTPURLResponse?, _ reponseData: Data?, _ errorInfo: Error?, _ isNotworkNot: Bool) -> Void

typealias NetWorkdownLoadFileResponseBlock = (_ httpsResponse: HTTPURLResponse?, _ fileData: Data?, _ errorInfo: Error?) -> Void

typealias MockWebserviceResponseBlock = (_ httpsResponse: Int?, _ reponseData: Data?, _ errorInfo: Error?) -> Void

protocol WebserviceAcessProtocol {
    // execute mock Api
    func executeRestMOCKAPI(url: String?, httpMethod: String, requestHeaders: [String: String]?, postBody: Data?, withQueryParameter queryParameter: [String: String]?, withCompletionHandler completionHandler: @escaping MockWebserviceResponseBlock)
    // execute rest api
    func executeRestAPI(url: String?, httpMethod: String, requestHeaders: [String: String]?, postBody: Data?, withQueryParameter queryParameter: [String: String]?, withCompletionHandler completionHandler: @escaping NetWorkWebserviceResponseBlock)

    func executeAPIDownLoadFile(url: String?, withCompletionHandler completionHandler: @escaping NetWorkdownLoadFileResponseBlock)
}
