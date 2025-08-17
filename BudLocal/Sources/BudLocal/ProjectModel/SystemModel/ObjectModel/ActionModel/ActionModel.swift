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
    
    // Action에 영향 범위
    public var sideEffects: Set<SideEffect> = []
    
    // Action이 호출하는 외부 시스템의 Flow
    // 이를 굳이 설명할 필요가 있을까?
    public internal(set) var linkedFlows: [FlowID] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
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
