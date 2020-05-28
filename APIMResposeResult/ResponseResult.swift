//
//  AppConfigurationSetting.swift
//  Umoe
//
//  Created by Manjit on 12/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//

import Foundation

/*!
 @protocol ResponseResult
 @discussion This protocol is reponsible for fetch reponse result if the webservice response is succuess other wise fail response status
 */
protocol ResponseResultOutPutProtocol {
    func getResponseResult<T>() -> T?
    func isResponseResultSuccess() -> Bool
    func getWebServiceResponseStatus() -> WebServiceResponseStatus
}

/*!
 @enum WebServiceResponseStatus
 @discussion This enum is reponsible for Webservice result status
 */
enum WebServiceResponseStatus {
    case WebServiceResponseStatus_Success // success staus if webservice result is success and connection is success
    case WebserviceResponseStatus_Failure(errorMessage: String) // failure status and message if theire are some othe errors.
    case WebserviceResponseStatus_NoInternet(errorMessage: String) // failure status and internet not available message if there is no internet available
}

/*!
  @class ResponseResult
 @discussion ResponseResult encapsulates the metadata associated
  with a URL load is responsible parser result and error result.
  ErrorResponseResult is responsible error result incase
 */

struct ResponseResult<T> {
    fileprivate let result: T? // parsing result it is generic type.
    fileprivate let errorResult: ErrorResponseResult? // error result for id someting happen
    fileprivate let httpsStatusCode: Int?

    // init with successresult and httpsstatus code
    /*!
     @method    initWithURL:httpsStatusCode:
     @abstract  initializer for ResponseResult objects.
     @param     successResult which is reponsible for parser object
     @param     httpsStatusCode an HTTP status code which is generated while get result form backend server.
     @result    the instance of the object, or NULL if an error occurred during initialization.
     */
    init(successResult: T?, withHttpsStatusCode httpsStatusCode: Int) {
        result = successResult
        errorResult = nil
        self.httpsStatusCode = httpsStatusCode
    }

    // init with failure result result and httpsstatus code
    /*!
     @method    initWithURL:httpsStatusCode:
     @abstract  initializer for ResponseResult objects.
     @param     errorResult which is reponsible for error message and error code if something happening
                response result.
     @param     httpsStatusCode an HTTP status code which is generated while get result form backend server.
     @result    the instance of the object, or NULL if an error occurred during initialization.
     */
    init(errorResult: ErrorResponseResult?, withHttpStausCode httpsStatusCode: Int) {
        result = nil
        self.errorResult = errorResult
        self.httpsStatusCode = httpsStatusCode
    }
}

extension ResponseResult: ResponseResultOutPutProtocol {
    /*!
     @method    isResponseResultSuccess:
     @result    boolen value true or false depening upon result
     @discussion this method is check web service connection and parsing object is success or not. if suucess the return true other wise return false.
     */
    func isResponseResultSuccess() -> Bool {
        switch getWebServiceResponseStatus() {
        case .WebServiceResponseStatus_Success:
            return true
        default:
            return false
        }
    }

    /*!
     @method    isConnectionSuccess:
     @result    boolen value true or false depening upon connection type
     @discussion this method is check https status and parser object if it is succes the return success other wise return false.
     */
    fileprivate func isConnectionSuccess() -> Bool {
        if isHttpsSuccess(), let _ = self.result {
            return true
        }
        return false
    }

    /*!
     @method    getResponseResult:
     @result    T value which is generic type, Because this resuklt class dont know which parserobject it keep at the time of parsing.
     @discussion this method is responsible for provide the response result.
     */
    func getResponseResult<T>() -> T? {
        return result as? T
    }

    /*!
     @method    getWebServiceResponseStatus:
     @result    WebServiceResponseStatus value which is associate enum type,it is pass success status and fail status depening upon result.
     @discussion this method is responsible for check webservice responce  if it fail then pass the message why it is failing .It failing due to internet coonection or due to request error or due to internal server error

     */
    func getWebServiceResponseStatus() -> WebServiceResponseStatus {
        if isHttpsSuccess() {
            if result != nil {
                return WebServiceResponseStatus.WebServiceResponseStatus_Success
            } else {
                return WebServiceResponseStatus.WebserviceResponseStatus_Failure(errorMessage: "")
            }
        } else {
            if let errorCode = self.httpsStatusCode {
                switch errorCode {
                case errorCode where (errorCode >= 500) && (errorCode <= 599):
                    return WebServiceResponseStatus.WebserviceResponseStatus_Failure(errorMessage: "Connection error")
                default:
                    return WebServiceResponseStatus.WebserviceResponseStatus_Failure(errorMessage: "")
                }
            } else {
                return WebServiceResponseStatus.WebserviceResponseStatus_Failure(errorMessage: "")
            }
        }
    }

    /*!
     @method    isHttpsSuccess:
     @result    Bool value which is boolen,it will pass true or false depening upon https status code.
     @discussion this method is responsible check the https status. If status is 2XX then it consider as response result is suceess other wise it fail.
     */

    fileprivate func isHttpsSuccess() -> Bool {
        if let httpsSatus = self.httpsStatusCode, httpsSatus == 200 {
            return true
        } else {
            return false
        }
    }
}
