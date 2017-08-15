//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    var disposeBag = DisposeBag()
    
    let didReceiveRemoteNotification: Observable<Void> = PublishSubject()
    let didRegisterForRemoteNotifications: Observable<Void> = PublishSubject()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Auto Aigration
        RealmManager.migration()
        
        UINavigationBar.appearance().tintColor = UIColor(white: 0.9, alpha: 1.0)
        
        let viewController = ViewController()
        windowInit(viewController)
        
        return true
    }
    
    //Init with NavigationController
    func windowInit(_ viewcontroller: UIViewController) {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.navigationController = UINavigationController(rootViewController: viewcontroller)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationItem.backBarButtonItem = backButtonItem

        self.window?.rootViewController = self.navigationController
        self.window?.makeKeyAndVisible()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
            
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    }
}
