//
//  ___FILENAME___
//  ___PACKAGENAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//___COPYRIGHT___
//

import RxSwift

public class BaseViewModel {
    
    // MARK: Properties
    /// Scope dispose to avoid leaking
    lazy var disposeBag = DisposeBag()
    
    /// Underlying variable that we'll listen to for changes
    private dynamic var _active: Bool = false
    
    /// Public «active» variable
    public dynamic var active: Bool {
        get { return _active }
        set {
            // Skip KVO notifications when the property hasn't actually changed. This is
            // especially important because self.active can have very expensive
            // observers attached.
            if newValue == _active { return }
            
            _active = newValue
            self.activeObservable.on(.next(_active))
        }
    }
    
    // Private
    private lazy var activeObservable: BehaviorSubject<Bool?> = {
        let ao = BehaviorSubject(value: Bool?(self.active))
        
        return ao
    }()
    
    // MARK: Life cycle
    
    /**
     Initializes a `BaseViewModel` a attaches to observe changes in the `active` flag.
     */
    init() {
        
    }
    
    /**
     Rx `Observable` for the `active` flag. (when it becomes `true`).
     
     Will send messages only to *new* & *different* values.
     */
    public lazy var didBecomeActive: Observable<BaseViewModel> = { [unowned self] in
        return self.activeObservable
            .filter { $0 == true }
            .map { _ in return self }
        }()
    
    /**
     Rx `Observable` for the `active` flag. (when it becomes `false`).
     
     Will send messages only to *new* & *different* values.
     */
    public lazy var didBecomeInactive: Observable<BaseViewModel> = { [unowned self] in
        return self.activeObservable
            .filter { $0 == false }
            .map { _ in return self }
        }()
}
