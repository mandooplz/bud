//
//  ActionModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite


// MARK: Object
@MainActor @Observable
public final class ActionModel: Debuggable, Hookable {
    // MARK: core
    init() {
        ActionModelManager.register(self)
    }
    func delete() {
        ActionModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let target = ActionID()
    
    public var name: String = "New Action"
    
    public internal(set) var captureStates: Set<StateID> = []
    public internal(set) var mutateStates: Set<StateID> = []
    
    public internal(set) var linkedFlows: [FlowID] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func duplicateAction() async {
        fatalError()
    }
    public func startFlow() async {
        fatalError()
    }
    
    public func removeAction() async {
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            ActionModelManager.container[self] != nil
        }
        public var ref: ActionModel? {
            ActionModelManager.container[self]
        }
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class ActionModelManager: Sendable {
    static var container: [ActionModel.ID: ActionModel] = [:]
    static func register(_ object: ActionModel) {
        container[object.id] = object
    }
    static func unregister(_ id: ActionModel.ID) {
        container[id] = nil
    }
}
