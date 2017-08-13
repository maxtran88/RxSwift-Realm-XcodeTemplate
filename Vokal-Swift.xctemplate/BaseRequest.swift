//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import AdSupport
import Alamofire
import RxAlamofire
import RxSwift
import SwiftyJSON
import ObjectMapper

public struct Response {
    var headerFields: [String : String]
    var json: JSON
    
    init(_ response: HTTPURLResponse, json: JSON) {
        self.headerFields = response.allHeaderFields as! [String : String]
        self.json = json
    }
}

class BaseRxRequest {
    
    public struct EndPoint {
        let mediaUpload: String = "media_upload"
    }
    
    static func baseAPIURLString() -> String {
        return "http://.../api/"
    }
    
    static func headers() -> HTTPHeaders {
        let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let myIDFA = ASIdentifierManager().advertisingIdentifier
        
        let headers: HTTPHeaders = [
            "app-version": appVersion,
            "platform": "iOS",
            "api-version": "1.5"
        ]
        return headers
    }
    
    public static func requestJson(path: String, param: [String: Any]?) -> Observable<(Response)> {
        let endPoint = baseAPIURLString() + path
        let headers: [String: String] = self.headers()
        
        let source: Observable<Response> = Observable.create { (observer: AnyObserver<Response>) -> Disposable in
            
            _ = RxAlamofire.requestJSON(.post, endPoint,
                                        parameters: param,
                                        encoding: JSONEncoding.default,
                                        headers: headers).subscribe(onNext: { (httpRes: HTTPURLResponse, jsonData: Any) in
                                            
                                            let statusCode = httpRes.statusCode
                                            //Save Realm
                                            let json: JSON = JSON(jsonData)
                                            mappingAndSaveRealm(json: json)
                                            
                                            observer.onNext(Response(httpRes, json: json))
                                            observer.onCompleted()
                                            
                                        }, onError: { (error: Error) in
                                            observer.onError(error)
                                            observer.onCompleted()
                                        })
            
            return Disposables.create()
        }

        return source
    }
    
    public static func mappingAndSaveRealm(json: JSON) {
        
        RealmManager.shared.write {
            /*Model (test data)
            if let modelsDataJson = json["data"]["models"].rawString(), modelsDataJson != "" {
                if let models = Mapper<Model>().mapArray(JSONString: modelsDataJson), 0 < models.count {
                    RealmManager.shared.add(elements: models)
                }
            }*/
            
        }
    }
}
