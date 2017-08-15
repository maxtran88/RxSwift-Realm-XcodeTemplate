//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import RxSwift
import RxCocoa
import RealmSwift
import RxRealm

public extension Results {
    public var allObjects: [Element] {
        return self.map { $0 }
    }
}

class RealmManager: NSObject {
    
    let realm: Realm
    fileprivate override init() {
        self.realm = try! Realm()
    }
    
    static let shared = RealmManager()
    
    class func migration() {
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let version: UInt64 = UInt64(Float(versionString)! * 10.0)
        let config = Realm.Configuration(
            
            schemaVersion: version,
            migrationBlock: { migration, oldSchemaVersion in
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func write(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            
            guard !realm.isInWriteTransaction else {
                closure()
                return
            }
            
            do {
                try realm.write {
                    closure()
                }
            } catch {
                assertionFailure("Failed to write: \(error)")
            }
        } else {
            
            let realm = try! Realm()
            
            guard !realm.isInWriteTransaction else {
                closure()
                return
            }
            
            do {
                try realm.write {
                    closure()
                }
            } catch {
                assertionFailure("Failed to write: \(error)")
            }
        }
    }
    
    func add(element: Object, update: Bool = true) {
        if Thread.isMainThread {
            
            write {
                
                self.realm.add(element, update: update)
            }
        } else {
            
            write {
                self.realm.add(element, update: update)
            }
        }
    }
    
    func add(elements: [Object], update: Bool = true) {
        if Thread.isMainThread {
            write {
                self.realm.add(elements, update: update)
            }
        } else {
            write {
                let realm = try! Realm()
                realm.add(elements, update: update)
            }
        }
    }
    
    func objects<T: RealmSwift.Object>( type: T.Type) -> RealmSwift.Results<T> {
        if Thread.isMainThread {
            return realm.objects(type)
        } else {
            let realm = try! Realm()
            return realm.objects(type)
        }
    }
    
    func find<T>() -> Results<T> {
        var result: Results<T>!
        result = objects(type: T.self)
        return result
    }
    
    func findById<T: Object>( id: Int ) -> T? {
        let results: Results<T> = findByIds(ids: [id])
        var resultDataObject: T? = nil
        
        for result in results {
            resultDataObject = result
            break
        }
        
        return resultDataObject
    }
    
    func findByIds<T>( ids: [Int] ) -> Results<T> {
        var result: Results<T>!
        
        result = objects(type: T.self).filter("id IN %@ AND isDeleted == false", ids)
        
        return result
    }

    func delete(_ object: RealmSwift.Object) {
        write {
            _ = Observable.from(object: object).subscribe(self.realm.rx.delete())
        }
    }
    
    func delete<S: Sequence>(_ objects: S) where S.Iterator.Element : Object {
        write {
            _ = Observable.from(optional: objects).subscribe(self.realm.rx.delete())
        }
    }
    
    func deleteObject(_ objects: [Object]) {
        write {
            _ = Observable.from(objects).subscribe(self.realm.rx.delete())
        }
    }
    
    func delete<T: Object>(_ objects: List<T>) {
        write {
            _ = Observable.collection(from: objects).subscribe(self.realm.rx.delete())
        }
    }
    
    func delete<T: Object>(_ objects: Results<T>) {
        write {
            _ = Observable.collection(from: objects).subscribe(self.realm.rx.delete()) //RxRealm
        }
    }
    
    func deleteAllObject() {
        write {
            self.realm.deleteAll()
        }
    }
    
    func refresh() {
        realm.refresh()
    }
}
