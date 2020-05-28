//
//  AppConfigurationSetting.swift
//  Umoe
//
//  Created by Manjit on 12/03/2019.
//  Copyright © 2019 Umoe. All rights reserved.
//
import Foundation

protocol APIMOutPutHandlerProtocol {
    func getMethodType() -> String?
    func getUrl() -> URL?
    func getRequestObject() -> Data?
    func getHeaderParameter() -> [String: String]?
    func getqueryParameter() -> [String: String]?
}

class APIM<R: RequestProtocol, T: Decodable>: NSObject {
    /*!
     @discusssion This enum is responsible for Https method type
     */
    enum HttpMethod: String {
        case Post = "POST"
        case Get = "GET"
        case Delete = "DELETE"
        case Put = "PUT"
        case Patch = "PATCH"
        case none = ""
    }

    /*!
     @discusssion _urlString is string keep url of each https request
     */
    private var _urlString: String?

    /*!
     @discusssion _requestBody type Data is responsible for Https request body.
     */
    private var _requestBody: Data?

    /*!
     @discusssion method type:enum which is responsible for HTTPs method.It change depending upon type you have set
     */
    private lazy var _method = APIM.HttpMethod.Get

    /*!
     @discusssion _queryParameter type:Dictonary which is used in url depending upon the request.
     */
    private var _queryParameter: [String: String]?

    /*!
     @discusssion _headers type:Dictonary which is used in different https request.
     */
    private var _headers: [String: String]?

    /*!
     @discusssion jsonHeaders type:Dictonary This is default header which is used in every https request.
     */
    private lazy var jsonHeaders: [String: String] = {
        var headers = [String: String]()
        headers.updateValue("application/json", forKey: "Content-Type")
        headers.updateValue("application/json", forKey: "Accept");
        if !ApplicationSetUp.shareInstance.userInfo.getAcessToken().isEmpty{
            headers.updateValue(ApplicationSetUp.shareInstance.userInfo.getAcessToken(), forKey: "Authorization")

        }
        return headers
    }()

    /*!
     @discusssion _completion type:Clouser This is uesed after webservice call.If pass result to respective class form where the closure is invoked.
     @param  sender : APIM,response:result of the parsing
     */
    private var _completion: ((_ sender: APIM, _ response: ResponseResult<T>) -> Void)? // completion handler for webservice response result.This will return once the webservice paring would completed.

    /*!
     @method    init()
     @discussion this method is responsible set all value nit at the time of allcation
     */
    override init() {
        super.init()
        _urlString = nil
        _requestBody = nil
        _method = .none
        _queryParameter = nil
        _headers = nil
    }

    /*!
     @method  init:url:method:queryParameter
     @param   url is string and is responsible for https request.
     @param   method is enum type which is responsible for https request method.
     @param   queryParameter is Dictonary type which is added in https url
     @discussion this method is responsible for set APM different attribute value.User should call this method if there are changes in query parameter.
     */
    public convenience init(url: String, method: HttpMethod, queryParameter: [String: String]?) {
        self.init()
        configureApiInformationWithUrl(url, withHttpsMethods: method, withUpdateHeaders: nil, withNewHeaders: jsonHeaders, withQueryParameter: queryParameter, withRequestInfo: nil)
    }

    /*!
     @method  init:url:method:queryParameter
     @param   url is string and is responsible for https request.
     @param   method is enum type which is responsible for https request method.
     @param   request is generic type which is added request dody in each https request
     @discussion this method is responsible for set APM different attribute value.User should call this method if there are changes in request value.
     */
    public convenience init(url: String, method: HttpMethod, request: R?) {
        self.init()
        configureApiInformationWithUrl(url, withHttpsMethods: method, withUpdateHeaders: nil, withNewHeaders: jsonHeaders, withQueryParameter: nil, withRequestInfo: request)
    }

    /*!
     @method  init:url:method:queryParameter
     @param   url is string and is responsible for https request.
     @param   method is enum type which is responsible for https request method.
     @param   request is generic type which is added request dody in each https request.
     @param   updateHeaders is Dictonary type which is added json header for extra header parameter.
     @discussion this method is responsible for set APM different attribute value.User should call this method if there are changes in request value and some hedaer parameter changes.
     */
    public convenience init(url: String, method: HttpMethod, request: R?, updateHeaders: [String: String]) {
        self.init()
        configureApiInformationWithUrl(url, withHttpsMethods: method, withUpdateHeaders: updateHeaders, withNewHeaders: jsonHeaders, withQueryParameter: nil, withRequestInfo: request)
    }

    /*!
     @method  init:url:method:queryParameter
     @param   url is string and is responsible for https request.
     @param   method is enum type which is responsible for https request method.
     @param   request is generic type which is added request dody in each https request.
     @param   queryParameter is Dictonary type which is added in https url
     @discussion this method is responsible for set APM different attribute value.User should call this method if there are changes in request value and query parameter.
     */
    public convenience init(url: String, method: HttpMethod, request: R?, queryParameter: [String: String]) {
        self.init()
        configureApiInformationWithUrl(url, withHttpsMethods: method, withUpdateHeaders: nil, withNewHeaders: jsonHeaders, withQueryParameter: queryParameter, withRequestInfo: request)
    }

    /*!
     @method  init:url:method:queryParameter
     @param   url is string and is responsible for https request.
     @param   method is enum type which is responsible for https request method.
     @param   request is generic type which is added request dody in each https request.
     @param   updateHeaders is Dictonary type which is added json header for extra header parameter.
     @discussion this method is responsible for set APM different attribute value.User should call this method if there are changes in request value,query parameter,and header information.
     */
    public convenience init(url: String, method: HttpMethod, request: R?, updateHeaders: [String: String], queryParameter: [String: String]) {
        self.init()
        configureApiInformationWithUrl(url, withHttpsMethods: method, withUpdateHeaders: updateHeaders, withNewHeaders: nil, withQueryParameter: queryParameter, withRequestInfo: request)
    }

    /*!
     @method    configureApiInformationWithUrl:url:method:httpMethod:updateHeaders:newHeaders:queryParameter:withRequestInfo
     @param  url which is string type which will update default ulr type
     @param  method is enum type  which will update Apim default method type
     @param  updateHeaders is Dictonary which will be update default Header type
     @param  newHeaders is Dictonary which will set as a new header.
     @param  queryParameter is Dictonary which update default query parameter.
     @param  request is generic type. which will update default request body type.
     @discussion  this method is reponsible for configuration and update default value
     */
    fileprivate func configureApiInformationWithUrl(_ url: String, withHttpsMethods method: HttpMethod, withUpdateHeaders updateHeaders : [String: String]?, withNewHeaders newHeaders: [String: String]?, withQueryParameter queryParameter: [String: String]?, withRequestInfo request: R?) {
        _urlString = url
        _method = method
        _headers = jsonHeaders
        if let newHeadersInfo = newHeaders {
            _headers = newHeadersInfo
        }
        if let queryParameterInfo = queryParameter {
            _queryParameter = queryParameterInfo
        }

        if let requestInfo = request {
            _requestBody = requestInfo.generateRequestObject()
        }
    }

    /*!
     @method  executeApi:completion:
     @param  completion is closure which is responsible for set default closure value.
     @discussion  This method is reponsible for extecute api call.
     */
    public func executeApi(completion: @escaping (_ sender: APIM, _ response: ResponseResult<T>) -> Void) {
        _completion = completion
        print("SEND time:", Date())
        #if MOCK
            let networkHandler: WebserviceAcessProtocol = NetWorkHandler()
            networkHandler.executeRestMOCKAPI(url: _urlString, httpMethod: _method.rawValue, requestHeaders: _headers, postBody: _requestBody, withQueryParameter: _queryParameter, withCompletionHandler: processMockResponseResult)
        #else
            let networkHandler: WebserviceAcessProtocol = NetWorkHandler()
            networkHandler.executeRestAPI(url: _urlString, httpMethod: _method.rawValue, requestHeaders: _headers, postBody: _requestBody, withQueryParameter: _queryParameter, withCompletionHandler: processHttpsResponseResult)
        #endif
    }

    /*!
     @method  executeForImage:completion:
     @param  completion is closure which is responsible for set default closure value.
     @discussion  This method is reponsible for extecute image api call.
     */
    public func executeForImage(completion: @escaping (_ sender: APIM, _ response: ResponseResult<T>) -> Void) {
        _completion = completion
//        let networkHandler:WebserviceAcessProtocol = NetWorkHandler();
//        networkHandler.executeAPIDownLoadFile(url: _urlString, httpMethod: _method.rawValue, requestHeaders:nil, postBody:_requestObject, withQueryParameter: self._queryParameter, withCompletionHandler: processHttpsResponseResult);
    }

    /*!
     @method  processMockResponseResult:completion:
     @param  completion is closure which is responsible for set default closure value.
     @discussion  This method is reponsible for extecute mock api call.this is used in uinit test case execution.
     */
    fileprivate func processMockResponseResult(_ httpsResponse: Int?, _ reponseData: Data?, _ errorInfo: Error?) {
        completeRequest(responseResult: handleResponseResultData(reponseData, withResponseCode: httpsResponse, withResponsError: errorInfo))
    }

    /*!
     @method processHttpsResponseResult:httpsResponse:reponseData:errorInfo:interNetAvailbale
     @param  httpsResponse is HTTPURLResponse,api Https response. This response will be output response after api response finish.
     @param reponseData:is Data which is the output result of Api call.
     @param errorInfo: is the error info if there are problem with api connection.
     @param interNetAvailbale:is boolean value which will check internet is availabe or not.
     @discussion this method is used as a output result of Api connection.
     */
    fileprivate func processHttpsResponseResult(_ httpsResponse: HTTPURLResponse?, _ reponseData: Data?, _ errorInfo: Error?, _ interNetAvailbale: Bool) {
        if interNetAvailbale {
            completeRequest(responseResult: handleResponseResultData(reponseData, withResponseCode: httpsResponse?.statusCode, withResponsError: errorInfo))
        } else {
            completeRequest(responseResult: noInternetConnection())
        }
    }

    /*!
     @method handleResponseResultData:reponseData:responseCode:errorInfo:interNetAvailbale
     @param reponseData:is Data which is output of Api call.
     @param  responseCode is Httpsstauscode,
     @param errorInfo: is the error info if there are problem with api connection.
     @param interNetAvailbale:is boolean value which will check internet is availabe or not.
     @result This method will return response result it combination of parser object and connection staus
     @discussion this method responsible for validate the response result which will come from network layer.
     */

    internal func handleResponseResultData(_ reponseData: Data?, withResponseCode responseCode: Int?, withResponsError error: Error?) -> ResponseResult<T> {
        if let responseResultData = reponseData, let code = responseCode {
            switch code {
            case 200, 203:
                return handleSuccessResponseWithResponseData(responseResultData, httpsStauscode: code)
            case 401:
                return handleUnAuthorizeError()
            default:
                return handlerErrorWithResponseData(responseResultData, withhttpErroCode: code)
            }
        } else {
            if let datastring = error {
                print(datastring.localizedDescription)
            }
            return handlerErrorWithResponseData(nil, withhttpErroCode: 500)
        }
    }

    /*!
     @method handleSuccessResponseWithResponseData:reponseData:httpsStauscode
     @param reponseData:is Data which is output of Api call.
     @param  responseCode is Httpsstauscode,
     @result This method will return success response result
     @discussion this method responsible for return sucess response result.Here the parsing happing using JSONDecoder method.
     */

    fileprivate func handleSuccessResponseWithResponseData(_ responseData: Data?, httpsStauscode statusCode: Int) -> ResponseResult<T> {
        if let response = responseData {
            let decoder = JSONDecoder()
            do {
                let responseObj = try decoder.decode(T.self, from: response)
                let responseResult: ResponseResult = ResponseResult(successResult: responseObj, withHttpsStatusCode: statusCode)
                if let datastring = NSString(data: response, encoding: String.Encoding.utf8.rawValue) {
                    print("Response ", datastring)
                }
                return responseResult
            } catch {
                return handleDefaultErrorWithCode(500)
            }
        } else {
            return handleDefaultErrorWithCode(500)
        }
    }

    /*!
     @method noInternetConnection
     @result This method will return failure response result
     @discussion this method responsible for return failure result with no internbet available.
     */
    func noInternetConnection() -> ResponseResult<T> {
        let response = ResponseResult<T>(errorResult: nil, withHttpStausCode: 999)
        return response
    }

    /*!
     @method handleDefaultErrorWithCode
     @result This method will return failure response result
     @discussion this method responsible for return failure result with default error ressponse
     */
    fileprivate func handleDefaultErrorWithCode(_ errorCode: Int) -> ResponseResult<T> {
        let response = ResponseResult<T>(errorResult: nil, withHttpStausCode: errorCode)
        return response
    }

    /*!
     @method handleUnAuthorizeError
     @result This method will return failure response result
     @discussion this method responsible for return failure result with unauthorize error message
     */
    fileprivate func handleUnAuthorizeError() -> ResponseResult<T> {
        let response = ResponseResult<T>(errorResult: nil, withHttpStausCode: 401)
        return response
    }

    /*!
     @method handlerErrorWithResponseData:reponseData:httpsErroCode
     @param reponseData error response data
     @param httpsErroCode httpcode for error
     @result This method will return failure response result
     @discussion this method responsible for return failure result with  error message
     */
    fileprivate func handlerErrorWithResponseData(_ reponseData: Data?, withhttpErroCode httpsErroCode: Int) -> ResponseResult<T> {
        if let response = reponseData {
            let decoder = JSONDecoder()
            do {
                let errorInfo = try decoder.decode(ErrorResponseResult.self, from: response)
                let responseResult: ResponseResult = ResponseResult<T>(errorResult: errorInfo, withHttpStausCode: httpsErroCode)
                if let datastring = NSString(data: response, encoding: String.Encoding.utf8.rawValue) {
                    print("Response ", datastring)
                }
                return responseResult
            } catch {
                return handleDefaultErrorWithCode(httpsErroCode)
            }
        } else {
            return handleDefaultErrorWithCode(httpsErroCode)
        }
    }

    /*!
     @method completeRequest:responseResult
     @result This method will return respose result
     @discussion this method pass result to respetive Apim manager
     */

    private func completeRequest(responseResult: ResponseResult<T>) {
        if let completionHandler = _completion {
            completionHandler(self, responseResult)
        }
    }
}

// if need to check the data for UI test case
extension APIM: APIMOutPutHandlerProtocol {
    func getMethodType() -> String? {
        return _method.rawValue
    }
    func getUrl() -> URL? {
        return URL(string: _urlString ?? "")
    }

    func getRequestObject() -> Data? {
        return _requestBody
    }

    func getHeaderParameter() -> [String: String]? {
        return _headers
    }

    func getqueryParameter() -> [String: String]? {
        return _queryParameter
    }
}
