// https://www.swiftbysundell.com/articles/caching-in-swift/

import Foundation

final class Cache<Key: Hashable, Value>: ObservableObject {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval

    init(dateProvider: @escaping () -> Date = Date.init, entryLifetime: TimeInterval = 12 * 60 * 60) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
    }

    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(value: value, expirationDate: date)
        
        objectWillChange.send()
        wrapped.setObject(entry, forKey: WrappedKey(key))
    }

    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        return entry.value
    }
    
    func needsUpdate(forKey key: Key) -> Bool {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return true
        }
        
        guard dateProvider() < entry.expirationDate else {
            return true
        }
        
        return false
    }

    func removeValue(forKey key: Key) {
        objectWillChange.send()
        wrapped.removeObject(forKey: WrappedKey(key))
    }
    
    func invalidateAllObjects() {
        wrapped.removeAllObjects()
    }
}

extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }

            insert(value, forKey: key)
        }
    }
}

private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key

        init(_ key: Key) { self.key = key }

        override var hash: Int { return key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension Cache {
    final class Entry {
        let value: Value
        let expirationDate: Date

        init(value: Value, expirationDate: Date) {
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}
