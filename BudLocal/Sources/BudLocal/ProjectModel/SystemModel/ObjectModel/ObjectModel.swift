//
//  ObjectModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite


// MARK: Object
@MainActor @Observable
public final class ObjectModel: Debuggable, Hookable {
    // MARK: core
    init(role: ObjectRole) {
        self.role = role
        
        ObjectModelManager.register(self)
    }
    func delete() {
        ObjectModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let target = ObjectID()
    
    public var name: String = "New Object"
    
    public nonisolated let role: ObjectRole
    public internal(set) var parent: ObjectID!
    public internal(set) var childs: [ObjectID] = []
    
    public internal(set) var states: [StateID: StateModel.ID] = [:]
    public internal(set) var actions: [ActionID: ActionModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func createChildObject() async  { }
    
    public func createNewState() async { }
    public func createNewAction() async { }
    
    public func removeObject() async { }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            ObjectModelManager.container[self] != nil
        }
        public var ref: ObjectModel? {
            ObjectModelManager.container[self]
        }
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class ObjectModelManager: Sendable {
    static var container: [ObjectModel.ID: ObjectModel] = [:]
    static func register(_ object: ObjectModel) {
        container[object.id] = object
    }
    static func unregister(_ id: ObjectModel.ID) {
        container[id] = nil
    }
}
