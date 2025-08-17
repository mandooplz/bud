//
//  StateModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite


// MARK: Object
@MainActor @Observable
public final class StateModel: Debuggable, Hookable {
    // MARK: core
    init(owner: ObjectModel.ID) {
        self.owner = owner
        
        StateModelManager.register(self)
    }
    func delete() {
        StateModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ObjectModel.ID
    public nonisolated let target = StateID()
    
    public var name: String = "New State"
    public internal(set) var accessLevel: AccessLevel = .readAndWrite
    public internal(set) var stateValue: StateValue?
    
    public internal(set) var getters: [GetterID: GetterModel.ID] = [:]
    public internal(set) var setters: [SetterID: SetterModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func setUpAccessor() async {
        fatalError()
    }
    
    public func appendGetter() async {
        fatalError()
    }
    public func appendSetter() async {
        fatalError()
    }
    
    public func duplicateState() async {
        fatalError()
    }
    
    public func removeState() async {
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            StateModelManager.container[self] != nil
        }
        public var ref: StateModel? {
            StateModelManager.container[self]
        }
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class StateModelManager: Sendable {
    static var container: [StateModel.ID: StateModel] = [:]
    static func register(_ object: StateModel) {
        container[object.id] = object
    }
    static func unregister(_ id: StateModel.ID) {
        container[id] = nil
    }
}

