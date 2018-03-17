//
//  ApiService.swift
//  Noodoe
//
//  Created by giggs on 17/03/2018.
//  Copyright © 2018 giggs. All rights reserved.
//

import Foundation

class ApiService {
    
    static let ApiHost = "https://watch-master-staging.herokuapp.com/api"
    static let AppId = "vqYuKPOkLQLYHhk4QTGsGKFwATT4mBIGREI2m8eD"
    
    class func login(username: String, password: String, handler: HttpHandler) -> Void {
        
        let parameters = "username=\(username)&password=\(password)"
        var url = "\(ApiHost)/login"
        url = HttpUtils.encodeUrl(url: url, queryString: parameters)
        
        var headers = [String: String]()
        headers["Content-Type"] = "application/x-www-form-urlencoded; charset=UTF-8"
        headers["X-Parse-Application-Id"] = AppId
        
        HttpService.request(url, method: .GET, headers: headers, handler: handler)
    }
    
    class func updateUser(dataModel: UserModel, handler: HttpHandler) -> Void {
        
        guard let token = AppConfig.userModel?.sessionToken,
            let objId = AppConfig.userModel?.objectId else {
                NSLog("Error -> Missing parameters.")
                return
        }
        
        let url = "\(ApiHost)/users/\(objId)"
        let data = try? JSONEncoder().encode(dataModel)
        
        var headers = [String: String]()
        headers["Content-Type"] = "application/json; charset=UTF-8"
        headers["X-Parse-Application-Id"] = AppId
        headers["X-Parse-Session-Token"] = token
        
        HttpService.request(url, method: .PUT, headers: headers, body: data, handler: handler)
    }
    
    class func desiralize<T: Decodable>(type: T.Type, data: Data?) -> T? {
        guard let _data = data else {
            return nil
        }
        
        return try? JSONDecoder().decode(type, from: _data)
    }
}
