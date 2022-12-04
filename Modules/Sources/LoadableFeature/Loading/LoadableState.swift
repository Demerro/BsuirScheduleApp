import Foundation

@propertyWrapper
public enum LoadableState<Value> {
    case initial
    case loading
    case error(LoadingError.State)
    case some(Value)
    
    public init(wrappedValue: Value? = nil) {
        if let wrappedValue {
            self = .some(wrappedValue)
        } else {
            self = .initial
        }
    }
    
    public var wrappedValue: Value? {
        get {
            guard case let .some(value) = self else { return nil }
            return value
        }
        set {
            guard let newValue else {
                assertionFailure()
                return self = .error(.unknown)
            }
            
            self = .some(newValue)
        }
    }
    
    public var projectedValue: Self {
      get { self }
      set { self = newValue }
    }
}

extension LoadableState: Equatable where Value: Equatable {}

extension LoadableState {
    public func map<U>(_ transform: (Value) -> U) -> LoadableState<U> {
        switch self {
        case .initial: return .initial
        case .loading: return .loading
        case let .error(error): return .error(error)
        case let .some(value): return .some(transform(value))
        }
    }
}
