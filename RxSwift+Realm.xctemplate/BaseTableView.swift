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

class BaseTableView: UITableView {
    
    lazy var disposeBag = DisposeBag()
    var myRefreshControl: UIRefreshControl!
    fileprivate let startedReflesh: PublishSubject<Void> = PublishSubject<Void>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
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
            let topCell = cellForRow(at: IndexPath(row: 0, section: 0))
            if let topCellOriginY = topCell?.frame.origin.y {
                currentRefreshControl.frame.origin.y = topCellOriginY - currentRefreshControl.frame.height
            }
        }
    }
    
    func initialize() {
        
        self.delegate = self
        self.emptyDataSetSource     = self
        self.emptyDataSetDelegate   = self
        
        self.backgroundColor = UIColor.white
        
        self.estimatedRowHeight = 20
        self.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func reloadData() {
        super.reloadData()
    }
    
    func refleshOn() {
        
        if #available(iOS 10.0, *) {
            
            self.refreshControl = UIRefreshControl()
            self.refreshControl?.addTarget(self, action: #selector(BaseTableView.refreshStart), for: .valueChanged)
            
            self.alwaysBounceVertical = true
            
        } else {
            if self.myRefreshControl == nil {
                self.myRefreshControl = UIRefreshControl()
                self.myRefreshControl.addTarget(self, action: #selector(BaseTableView.refreshStart), for: .valueChanged)
                self.addSubview(self.myRefreshControl)
                
                self.alwaysBounceVertical = true
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
    
    open func refreshStart() {
        startedReflesh.on(.next())
    }
    
    deinit {
        
    }
}

extension BaseTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
