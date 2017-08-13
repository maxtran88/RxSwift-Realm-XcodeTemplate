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
import DZNEmptyDataSet

class BaseCollectionView: UICollectionView {
    
    lazy var disposeBag = DisposeBag()
    var myRefreshControl: UIRefreshControl!
    
    fileprivate let startedReflesh: PublishSubject<Void> = PublishSubject<Void>()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var currentRefreshControl: UIRefreshControl!
        
        if #available(iOS 10.0, *) {
            currentRefreshControl = self.refreshControl
        } else {
            currentRefreshControl = self.myRefreshControl
        }
        
        if currentRefreshControl != nil {
            let topCell = cellForItem(at: IndexPath(row: 0, section: 0))
            if let topCellOriginY = topCell?.frame.origin.y {
                currentRefreshControl.frame.origin.y = topCellOriginY - currentRefreshControl.frame.height
            }
        }
    }
    
    func initialize() {
        
        self.emptyDataSetSource     = self
        self.emptyDataSetDelegate   = self
        
        self.backgroundColor        = UIColor.white
    }
    
    override func reloadData() {
        super.reloadData()
        
    }
    
    func regleshOn() {
        
        self.alwaysBounceVertical = true
        
        if #available(iOS 10.0, *) {
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(BaseCollectionView.reflesshStart), for: .valueChanged)
        } else {
            if self.myRefreshControl == nil {
                self.myRefreshControl = UIRefreshControl()
                self.myRefreshControl.addTarget(self, action: #selector(BaseCollectionView.reflesshStart), for: .valueChanged)
                self.addSubview(self.myRefreshControl)
            }
        }
    }
    
    func endRefreshing() {
        
        if #available(iOS 10.0, *) {
            
            if let reflesh = self.refreshControl {
                reflesh.endRefreshing()
            }
        } else {
            if self.myRefreshControl != nil {
                self.myRefreshControl.endRefreshing()
            }
        }
    }

    func startedRefleshEvent() -> PublishSubject<Void> {
        return startedReflesh
    }
    
    func reflesshStart() {
        startedReflesh.on(.next())
    }

    deinit {
        
    }
}

extension BaseCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

