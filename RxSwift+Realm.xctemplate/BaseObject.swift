//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import SwiftyJSON
import RealmSwift
import ObjectMapper

public class BaseObject: Object, Mappable {
    
    public dynamic var id: Int = 0
    public dynamic var isDeleted: Bool = false
    
    public static let dateFormat: String = "yyyy-MM-dd'T'HH:mm:ssZZZ"
    public static let initDate: Date = Date(timeIntervalSince1970: 0)
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience public init?(map: Map) {
        self.init()
        mapping(map: map)
    }
    
    public static func findById<T: RealmSwift.Object>(id: Int) -> Results<T> {
        return RealmManager.shared.objects(type: T.self).filter("id == %d AND isDeleted == false", id).sorted(byKeyPath: "id", ascending: true)
    }
    
    public func mapping(map: Map) {
        id          <- map["id"]
        isDeleted   <- map["isDeleted"]
    }
}

extension BaseObject {
    
    func toDic() -> [String:Any] {
        var dic: [String: Any] = [:]
        
        for prop in self.objectSchema.properties as [Property]! {
            if let object = self[prop.name] {
                if object is NSDate || object is Date {
                    let formatter: DateFormatter = DateFormatter()
                    formatter.dateFormat = BaseObject.dateFormat
                    formatter.timeZone = TimeZone(abbreviation: "UTC")
                    let str: String = formatter.string(from: object as! Date)
                    dic.updateValue(str, forKey: prop.name)
                } else {
                    dic.updateValue(object, forKey: prop.name)
                }
            }
        }
        return dic
    }
}
