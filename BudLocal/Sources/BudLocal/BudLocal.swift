//
//  BudLocal.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("BudLocal")


// MARK: Object
@MainActor
public final class BudLocal: Debuggable {
    // MARK: core
    public init() {
        BudLocalManager.register(self)
    }
    func delete() {
        BudLocalManager.unregister(self.id)
    }
    
    
    // MARK: state
    nonisolated let id = ID()
    
    public internal(set) var projects: [ProjectID: ProjectModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    
    
    // MARK: action
    public func createProject() async {
        fatalError()
    }
    
    
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
    fileprivate static func unregister(_ id: BudLocal.ID) {
        container[id] = nil
    }
}
