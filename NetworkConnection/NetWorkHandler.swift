//
//  AppConfigurationSetting.swift
//  Umoe
//
//  Created by Manjit on 13/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//

import UIKit

let timeInterVal: Int = 5 // default time interval

class NetWorkHandler {
    private static var isNetWorkReachable = true
}

extension NetWorkHandler: WebserviceAcessProtocol {
    // execute mock api when application is

    func executeRestMOCKAPI(url: String?, httpMethod _: String, requestHeaders _: [String: String]?, postBody _: Data?, withQueryParameter _: [String: String]?, withCompletionHandler completionHandler: @escaping MockWebserviceResponseBlock) {
        if let stringUrl = url {
            if let path = Bundle.main.path(forResource: stringUrl, ofType: nil) {
                do {
                    let jsonData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        // your code here
                        completionHandler(200, jsonData, nil)
                    }
                } catch {}
            } else {
                completionHandler(nil, nil, nil)
            }
        }
    }

    /*!
     @method    executeRestAPI:url:withHttpsMethod:httpMethod:requestHeaders:postBody:queryParameter:completionHandler
     @param     url which is reponsible for connect the server
     @param     The HTTP request method of the receiver.
     @param     requestHeaders  header parameter for
     @param     postBody to added in each request
     @result    return return (_ httpsResponse:HTTPURLResponse?,_ reponseData:Data?,_ errorInfo:Error?,_ isNotworkNot:Bool)  connection status and response data,error, and is network reachable or not. .
     */

    func executeRestAPI(url: String?, httpMethod: String, requestHeaders: [String: String]?, postBody: Data?, withQueryParameter queryParameter: [String: String]?, withCompletionHandler completionHandler: @escaping NetWorkWebserviceResponseBlock) {
        if NetWorkHandler.isNetWorkReachable {
            if let urlRequest = self.getRequestForUrl(url, withQueryParameters: queryParameter, withHttpsMethod: httpMethod, withRequestHeaders: requestHeaders, withPostData: postBody) {
                let task = DefaultUrlSession.sharedInstance.urlSession.dataTask(with: urlRequest) { responseData, response, responseError in

//                    print("receive time",Date.init().description);

                    DispatchQueue.main.async {
                        if let errorInfo = responseError {
                            completionHandler(response as? HTTPURLResponse, nil, errorInfo, true)
                        } else {
                            completionHandler(response as? HTTPURLResponse, responseData, nil, true)
                        }
                        return
                    }
                }
                task.resume()
            }
        } else {
            completionHandler(nil, nil, nil, false)
        }
    }

    /*!
     @method    executeAPIDownLoadFile:url
     @param     url which is reponsible for connect the server and down load the image
     @result    return (_ httpsResponse:HTTPURLResponse?,fileLocation?,_ errorInfo:Error?,_ isNotworkNot:Bool)  return connection status and response data,error, and is network reachable or not.
     */
    func executeAPIDownLoadFile(url: String?, withCompletionHandler completionHandler: @escaping NetWorkdownLoadFileResponseBlock) {
        if let urlRequest = self.getRequestForUrl(url, withQueryParameters: nil, withHttpsMethod: "Get", withRequestHeaders: nil, withPostData: nil) {
            let task = DefaultUrlSession.sharedInstance.urlSession.dataTask(with: urlRequest) { responseData, response, responseError in

                DispatchQueue.main.async {
                    if let errorInfo = responseError {
                        completionHandler(response as? HTTPURLResponse, nil, errorInfo)
                    } else {
                        completionHandler(response as? HTTPURLResponse, responseData, nil)
                    }
                }
            }
            task.resume()
        } else {
            completionHandler(nil, nil, nil)
        }
    }

    /*!
     @method    getRequestForUrl:withQueryParameters:withHttpsMethod:withRequestHeaders
     @param     url which is reponsible for connect the server
     @param     queryParameters which is reponsible add extraparameter to url
     @param     The HTTP request method of the receiver.
     @param     headersParameter to added in each request
     @param     postData is reponsible add in each request.
     @result    return (_ httpsResponse:HTTPURLResponse?,_ reponseData:Data?,_ errorInfo:Error?,_ isNotworkNot:Bool)  return  connection status and response data,error, and is network reachable or not.
     */

    fileprivate func getRequestForUrl(_ url: String?, withQueryParameters queryParameters: [String: String]?, withHttpsMethod httpMethod: String, withRequestHeaders headersParameter: [String: String]?, withPostData postData: Data?) -> URLRequest? {
        
        if let requestUrlString = url {
            // Discussion Adding query parameter
            var urlComponets = URLComponents(string: requestUrlString)
            if let queryParameter = queryParameters {
                urlComponets?.setQueryItems(with: queryParameter)
            }
            if let url = urlComponets?.url {
//                print(url)
                var apiRequest = URLRequest(url: url)

                apiRequest.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
                apiRequest.httpMethod = httpMethod;
                
                if let headerParametersList = headersParameter {
//                    print("the header parameter is ", headerParametersList.description);
                    apiRequest.allHTTPHeaderFields = headerParametersList
                    
                    print("The heasder parameter is %@",headerParametersList.description);

                }
                if let body = postData {
                    apiRequest.httpBody = body
                    if let datastring = NSString(data: body, encoding: String.Encoding.utf8.rawValue){
                        print(datastring)
                    }
                }
                return apiRequest
            } else {
                return nil
            }
        }
        return nil
    }
}

// adding query prameter
extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
