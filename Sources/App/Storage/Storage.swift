//
//  Storage.swift
//  App
//
//  Created by Luke Stringer on 16/06/2018.
//

import Foundation

// TODO: Way to get a specific entry out

/// Conform to the Storage protocol to faciltate the storage of a Storable entity.
protocol Storage {
    
    /// The type of entity to store.
    associatedtype Entity: Storable
    
    /// The unique key used as a namespace for the storage.
    static var key: String { get }
    
    
    /// Add an entity into storage.
    ///
    /// - Parameter entity: The entity to store.
    func add(_ entity: Entity)
    
    
    /// Add multiple entities into storage
    ///
    /// - Parameter entities: The entities to to store.
    func add(_ entities: [Entity])
    
    
    /// Remove an entity from storage if it exists.
    ///
    /// - Parameter entity: The entity to remove from storage.
    func remove(_ entity: Entity)
    
    
    /// Get all the stored entities.
    ///
    /// - Returns: All the stored entities.
    func all() -> [Entity]
    
    
    /// Reset the storage by removing any stored entities
    func reset()
    
    
    /// Callback function, called when the storage is updated (entities are added or removed).
    ///
    /// - Parameter entities: The entities currently in storage.
    func didUpdate(to entities: [Entity])
}


/// Conform to the Storage protocol to facilitate encoding a type for storage, and decoding a type back out of storage.
protocol Storable {
    
    /// Encode a type into data ready for storage.
    ///
    /// - Returns: A data representation of the type.
    func encode() -> Data
    
    
    /// Decode data back into the type.
    ///
    /// - Parameter data: The data from storage.
    /// - Returns: A instance of the type as decoded from the data.
    static func decode(from data: Data) -> Self
}


// MARK: - Default implementation
extension Storage {
    
    func add(_ entity: Entity) {
        // TODO: Disallow adding entity twice?
        // Need a unique key / entity is hashable if so
        let toStore = allAsData() + [entity.encode()]
        setStored(toStore)
    }
    
    func add(_ entities: [Entity]) {
        entities.forEach { add($0) }
    }
    
    func remove(_ entity: Entity) {
        var toStore = allAsData()
        guard let index = toStore.index(of: entity.encode()) else { return }
        toStore.remove(at: index)
        setStored(toStore)
    }
    
    func all() -> [Entity] {
        return allAsData().compactMap { Entity.decode(from: $0) }
    }
    
    func reset() {
        setStored([Data]())
    }
}


// MARK: - Using UserDefaults as a storage mechanism
fileprivate extension Storage {
    
    private func allAsData() -> [Data] {
        if let current = UserDefaults.standard.array(forKey: Self.key) as? [Data] {
            return current
        }
        return [Data]()
    }
    
    private func setStored(_ toStore: [Data]) {
        UserDefaults.standard.set(toStore, forKey: Self.key)
        didUpdate(to: all())
    }
}

extension Storage {
    // Make function optional
    func didUpdate(to entities: [Entity]) { }
}
