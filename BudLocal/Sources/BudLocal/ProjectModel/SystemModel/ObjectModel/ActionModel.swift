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
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New Action"
    
    // Action에 영향을 미치는 범위
    public internal(set) var failureEffects: Set<SideEffect> = []
    public internal(set) var successEffects: Set<SideEffect> = []
    public var selectedObject: ObjectID? = nil
    public var selectedEffect: SideEffect.Diff? = nil
    
    // Action이 호출하는 외부 Flow들
    public internal(set) var linkedFlows: [FlowID] = []
    public var selectedExternalFlow: FlowID? = nil
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func addFailureEffect() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.actionModelIsDeleted)
            logger.failure("ActionModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        logger.failure("구현이 필요합니다.")
    }
    public func addSuccessEffect() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.actionModelIsDeleted)
            logger.failure("ActionModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        logger.failure("구현이 필요합니다.")
    }
    
    public func createFlow() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.actionModelIsDeleted)
            logger.failure("ActionModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        logger.failure("구현이 필요합니다.")
    }
    public func linkFlow() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.actionModelIsDeleted)
            logger.failure("ActionModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        // mutate
        // selectedExternalFlow를 이용해 linkedFlows 추가
        logger.failure("구현이 필요합니다.")
    }
    
    public func removeAction() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.actionModelIsDeleted)
            logger.failure("ActionModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        let objectModelRef = self.owner.ref!
        
        
        // mutate
        objectModelRef.actions[self.target] = nil
        self.delete()
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
    
    public enum Error: String, Swift.Error {
        case actionModelIsDeleted
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
