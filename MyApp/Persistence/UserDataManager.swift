//
//  UserDataManager.swift
//  MyApp
//
//  Created by Julian on 19/07/23.
//

import Foundation
import CoreData

// MARK: - User Data Manager Protocol
protocol UserDataManagerProtocol {
    func saveUser(_ user: User) async throws
    func fetchUser(by id: UUID) async throws -> User?
    func fetchAllUsers() async throws -> [User]
    func deleteUser(_ user: User) async throws
    func clearAllUsers() async throws
}

// MARK: - User Data Manager
final class UserDataManager: UserDataManagerProtocol {
    
    private let persistenceController: PersistenceController
    
    init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
    }
    
    func saveUser(_ user: User) async throws {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        let userEntity = results.first ?? UserEntity(context: context)
        
        userEntity.id = user.id
        userEntity.email = user.email
        userEntity.firstName = user.firstName
        userEntity.lastName = user.lastName
        userEntity.avatar = user.avatar
        userEntity.createdAt = user.createdAt
        userEntity.isActive = user.isActive
        
        try context.save()
    }
    
    func fetchUser(by id: UUID) async throws -> User? {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        return results.first?.toUser()
    }
    
    func fetchAllUsers() async throws -> [User] {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        return results.compactMap { $0.toUser() }
    }
    
    func deleteUser(_ user: User) async throws {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        let results = try context.fetch(fetchRequest)
        results.forEach { context.delete($0) }
        
        try context.save()
    }
    
    func clearAllUsers() async throws {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = UserEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try context.execute(deleteRequest)
        try context.save()
    }
}

// MARK: - UserEntity Extension
extension UserEntity {
    func toUser() -> User? {
        guard let id = id,
              let email = email,
              let firstName = firstName,
              let lastName = lastName,
              let createdAt = createdAt else {
            return nil
        }
        
        return User(
            id: id,
            email: email,
            firstName: firstName,
            lastName: lastName,
            avatar: avatar,
            createdAt: createdAt,
            isActive: isActive
        )
    }
}
