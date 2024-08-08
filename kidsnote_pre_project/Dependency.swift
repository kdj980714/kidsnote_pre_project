import Foundation

final class Container {
    static let shared = Container()
    private init() { }
    var searchClient: SearchClient { .liveValue }
    var detailBookClient: DetailBookClient { .liveValue } // .testValue
}

@propertyWrapper
struct Dependency<T> {
    
    let wrappedValue: T
    
    init(_ keyPath: KeyPath<Container, T>) {
        let container = Container.shared
        wrappedValue = container[keyPath: keyPath]
    }
}
