//
//  ActionModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("ActionModel")


// MARK: Object
@MainActor @Observable
public final class ActionModel: Debuggable, Hookable {
    // MARK: core
    init(owner: ObjectModel.ID) {
        self.owner = owner
        
        ActionModelManager.register(self)
    }
    func delete() {
        ActionModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ObjectModel.ID
    public nonisolated let target = ActionID()
    
    public var name: String = "New Action"
    
    // Action에 영향을 미치는 범위
    public internal(set) var failureEffects: Set<SideEffect> = []
    public internal(set) var successEffects: Set<SideEffect> = []
    public var objectSelection: ObjectID? = nil
    public var effectSelection: SideEffect.Diff? = nil
    
    // Action이 호출하는 외부 Flow들
    public internal(set) var linkedFlows: [FlowID] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func addFailureEffect() async {
        fatalError()
    }
    public func addSuccessEffect() async {
        fatalError()
    }
    
    public func duplicateAction() async {
        fatalError()
    }
    public func createFlow() async {
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
    
    public struct SideEffect: Sendable, Hashable {
        public let object: ObjectID
        public let diff: Diff
        
        public enum Diff: Sendable, Hashable {
            case create
            case modify(StateID)
            case delete
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
