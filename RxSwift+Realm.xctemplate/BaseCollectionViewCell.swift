//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import UIKit
import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {
    
    lazy var disposeBag = DisposeBag()
    let onPrepareForReuse: Observable<Void> = PublishSubject()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        (self.onPrepareForReuse as? PublishSubject<Void>)?.on(.next())
    }
    
}
