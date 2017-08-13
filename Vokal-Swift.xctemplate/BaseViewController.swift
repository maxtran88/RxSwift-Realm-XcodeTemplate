//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

enum HeaderType {
    case normal
    case oblique
}

class BaseViewController: UIViewController {

    //RxSwift
    lazy var disposeBag = DisposeBag()
    let rx_viewDidLoad: Observable<Void> = PublishSubject()
    let rx_viewWillApper: Observable<Void> = PublishSubject()
    let rx_viewDidAppear: Observable<Void> = PublishSubject()
    let rx_viewWillDisappear: Observable<Void> = PublishSubject()
    let rx_viewDidDisappear: Observable<Void> = PublishSubject()
    
    let rx_tapGesture: Observable<Void> = PublishSubject()
    
    private let obliqueHeaderView: ObliqueHeaderView = ObliqueHeaderView()
    private let titleImageView = UIImageView()
    private let navigationBackgroundView = UIView()
    
    public var isHiddenBackButtonTextOnNavigationBar = false
    
    private var headerType: HeaderType = .normal {
        didSet {
            configureHeader()
        }
    }
    
    public func setOblique(scrollView: UIScrollView, image: UIImage?, descroption: String) {
        headerType = .oblique
        titleImageView.image = image
        obliqueHeaderView.setDescription(descroption)
        configureSyncScrollView(scrollView)
    }
    
    public func navigationBarTransparent() {
        navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        navigationController!.navigationBar.shadowImage = UIImage()
        navigationController!.navigationBar.isTranslucent = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isHiddenBackButtonTextOnNavigationBar {
            let backButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            navigationItem.backBarButtonItem = backButtonItem
        }
        
        self.navigationController?.navigationBar.tintColor = UIColor(white: 0.9, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.darkJungleGreen()
        self.navigationController?.navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.white ]
        
        titleImageView.frame.size = CGSize(width: 87, height: 15)
        titleImageView.frame.origin = CGPoint(x: 22, y: 71)
        titleImageView.isHidden = true
        
        navigationBackgroundView.backgroundColor = UIColor(red: 20/255.0, green: 35/255.0, blue: 50/255.0, alpha: 1.0)
        navigationBackgroundView.frame = self.navigationController?.navigationBar.frame ?? CGRect.zero
        navigationBackgroundView.isHidden = true
        
        obliqueHeaderView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: view.frame.width, height: 240))
        obliqueHeaderView.isHidden = true
        
        view.addSubview(navigationBackgroundView)
        view.addSubview(titleImageView)
        view.insertSubview(obliqueHeaderView, at: 0)
        
        //viewTap
        view.rx.tapGesture(numberOfTouchesRequired: 1, numberOfTapsRequired: 1) { (tap: UITapGestureRecognizer) in
            tap.delegate = self
            tap.cancelsTouchesInView = false
            }.subscribe(onNext: { (_: UITapGestureRecognizer) in
            (self.rx_tapGesture as? PublishSubject<Void>)?.on(.next())
        }).disposed(by: disposeBag)
        
        (rx_viewDidLoad as? PublishSubject<Void>)?.on(.next())
    }
    
    func viewWillAppear(_ animated: Bool, isNavigationBarHidden: Bool = false) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)

        (rx_viewWillApper as? PublishSubject<Void>)?.on(.next())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        (rx_viewDidAppear as? PublishSubject<Void>)?.on(.next())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (rx_viewWillDisappear as? PublishSubject<Void>)?.on(.next())
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        (rx_viewDidDisappear as? PublishSubject<Void>)?.on(.next())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.bringSubview(toFront: navigationBackgroundView)
        view.bringSubview(toFront: titleImageView)
    }
    
    deinit {
        
    }
    
    private func configureHeader() {
        
        if headerType == .oblique {
            
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            titleImageView.isHidden = false
            obliqueHeaderView.isHidden = false
            navigationBackgroundView.isHidden = false
        } else {
            
            navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            navigationController?.navigationBar.shadowImage = nil
            titleImageView.isHidden = true
            obliqueHeaderView.isHidden = true
            navigationBackgroundView.isHidden = true
        }
    }
    
    public func configureSyncScrollView(_ scrollView: UIScrollView) {
        scrollView.rx.contentOffset.subscribe { (event) in
            guard let offsetY: CGFloat = event.element?.y,
                offsetY > 0 else {
                return
            }
            
            let moveRatio: CGFloat = offsetY / 50
            
            let titleImagePositionY = max(71 - 38 * moveRatio, 33)
            self.titleImageView.frame.origin.y = titleImagePositionY
            
            let headerHeight = max(240 - 60 * moveRatio, 180)
            self.obliqueHeaderView.frame.size.height = headerHeight
            
        }.disposed(by: disposeBag)
    }
}

extension BaseViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if gestureRecognizer.view == touch.view {
            return true
        } else {
            return false
        }
    }
}
