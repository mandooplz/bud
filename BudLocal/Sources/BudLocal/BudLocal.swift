//
//  BudLocal.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation


// MARK: Object
@MainActor
public final class BudLocal: Sendable {
    // MARK: core
    
    
    // MARK: state
    nonisolated let id = ID()
    
    
    // MARK: action
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        let value: UUID = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            BudLocalManager.container[self] != nil
        }
        public var ref: BudLocal? {
            BudLocalManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class BudLocalManager: Sendable {
    // MARK: state
    fileprivate static var container: [BudLocal.ID: BudLocal] = [:]
    fileprivate static func register(_ object: BudLocal) {
        container[object.id] = object
    }
}
