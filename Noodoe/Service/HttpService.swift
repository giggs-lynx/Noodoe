//
//  HttpService.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import Foundation

class HttpService {
    
    public enum Method: String {
        case GET, POST, PUT
    }
    
    public class func request(_ url: String, method: HttpService.Method, headers: Dictionary<String, String>? = nil, body: Any? = nil, handler: HttpHandler? = nil) -> Void {
        
        guard let req = createRequest(url, method: method, headers: headers, body: body) else {
            return
        }
        
        var config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        config.urlCache = nil
        
        let session = URLSession(configuration: config)
        
        NSLog("Debug -> \n\(req.cURL)")
        
        session.dataTask(with: req) { data, response, error in
            defer {
                session.invalidateAndCancel()
            }
            
            guard error == nil else {
                handler?.errorHandler(error!)
                return
            }
            
            guard let res = response as? HTTPURLResponse else {
                let errorMessage = "Can not get HTTP response."
                let err = SimpleError.RuntimeError(errorMessage)
                handler?.errorHandler(err)
                return
            }
            
            handler?.successHandler(data, res)
            
            }.resume()
        
    }
    
    private class func createRequest(_ url: String, method: HttpService.Method, headers: Dictionary<String, String>? = nil, body: Any? = nil) -> URLRequest? {
        
        guard let _url = URL(string: url) else {
            return nil
        }
        
        var req = URLRequest(url: _url)
        req.httpMethod = method.rawValue
        
        headers?.forEach { e in
            req.addValue(e.value, forHTTPHeaderField: e.key)
        }
        
        req.allHTTPHeaderFields = headers
        req.httpBody = body as? Data
        
        return req
    }
    
}

class HttpHandler {
    
    typealias SuccessHandler = (Data?, HTTPURLResponse) -> Void
    typealias ErrorHandler = (Error) -> Void
    
    var successHandler: SuccessHandler
    var errorHandler: ErrorHandler
    
    init(successHandler: @escaping SuccessHandler, errorHandler: ErrorHandler? = HttpHandler.defaultErrorHandler) {
        self.successHandler = successHandler
        self.errorHandler = errorHandler!
    }
    
    static let defaultErrorHandler: ErrorHandler = { error in
        let errorMessage = error.localizedDescription
        NSLog("Error -> \(errorMessage)")
    }
    
}

class HttpUtils {
    
    static func encodeUrl(url: String, queryString: String) -> String {
        let encoded = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        return "\(url)?\(encoded)"
    }
    
}

extension URLRequest {
    
    /// Returns a cURL command for a request
    /// - return A String object that contains cURL command or "" if an URL is not properly initalized.
    public var cURL: String {
        
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0
            else {
                return ""
        }
        
        var curlCommand = "curl \n"
        
        // URL
        curlCommand = curlCommand.appendingFormat(" '%@' \n", url.absoluteString)
        
        // Method if different from GET
        if "GET" != httpMethod {
            curlCommand = curlCommand.appendingFormat(" -X %@ \n", httpMethod)
        }
        
        // Headers
        let allHeadersFields = allHTTPHeaderFields!
        let allHeadersKeys = Array(allHeadersFields.keys)
        let sortedHeadersKeys  = allHeadersKeys.sorted(by: <)
        for key in sortedHeadersKeys {
            curlCommand = curlCommand.appendingFormat(" -H '%@: %@' \n", key, self.value(forHTTPHeaderField: key)!)
        }
        
        // HTTP body
        if let httpBody = httpBody, httpBody.count > 0 {
            let httpBodyString = String(data: httpBody, encoding: String.Encoding.utf8)!
            let escapedHttpBody = URLRequest.escapeAllSingleQuotes(httpBodyString)
            curlCommand = curlCommand.appendingFormat(" --data '%@' \n", escapedHttpBody)
        }
        
        return curlCommand
    }
    
    /// Escapes all single quotes for shell from a given string.
    static func escapeAllSingleQuotes(_ value: String) -> String {
        return value.replacingOccurrences(of: "'", with: "'\\''")
    }
}
