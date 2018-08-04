//
//  Storage.swift
//  App
//
//  Created by Luke Stringer on 16/06/2018.
//

import Foundation
import FluentProvider

/// Conform to the Storage protocol to faciltate the storage of a Storable entity.
protocol StorageService {
	
	/// The type of entity to store.
	associatedtype Entity: Storable
	
	
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
	
	
	/// Get the first entity matching it's unique ID
	///
	/// - Parameter entityID: The unique ID for the entity to get
	/// - Returns: The first entity in storage with a matching uniqueID, or nil if not found.
	func getFirst(matching entityID: Entity.UniqueIDType) -> Entity?
}


/// Conform to the Storage protocol to facilitate encoding a type for storage, and decoding a type back out of storage.
protocol Storable: Model, Preparation {
	
	/// The type of the unique ID.
	associatedtype UniqueIDType: Hashable
	
	/// The unique ID for the entity.
	var uniqueID: UniqueIDType { get }
}


// MARK: - Default implementation
extension StorageService {
	
	func add(_ entity: Entity) {
		try! entity.save()
		callDidUpdate()
	}
	
	func add(_ entities: [Entity]) {
		entities.forEach { add($0) }
	}
	
	func remove(_ entity: Entity) {
		try! entity.delete()
		callDidUpdate()
	}
	
	func remove(matching entityID: Entity.UniqueIDType) {
		if let entity = getFirst(matching: entityID) {
			remove(entity)
		}
	}
	
	func all() -> [Entity] {
		do {
			return try Entity.all()
		}
		catch {
			print(error)
			abort()
		}
	}
	
	func getFirst(matching entityID: Entity.UniqueIDType) -> Entity? {
		return all().first(where: { return $0.uniqueID == entityID} )
	}
	
	func reset() {
		try! Entity.all().forEach { try! $0.delete() }
	}
}

fileprivate extension StorageService {
	func callDidUpdate() {
		didUpdate(to: try! Entity.all())
	}
}


extension StorageService {
	// Make function optional
	func didUpdate(to entities: [Entity]) { }
}
