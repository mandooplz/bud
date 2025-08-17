//
//  ObjectModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("ObjectModel")


// MARK: Object
@MainActor @Observable
public final class ObjectModel: Debuggable, Hookable {
    // MARK: core
    init(owner: SystemModel.ID, role: ObjectRole, parent: ObjectID? = nil) {
        self.owner = owner
        self.role = role
        self.parent = parent
        
        ObjectModelManager.register(self)
    }
    func delete() {
        ObjectModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: SystemModel.ID
    public nonisolated let target = ObjectID()
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New Object"
    public nonisolated let role: ObjectRole
    public internal(set) var parent: ObjectID!
    public internal(set) var childs: Set<ObjectID> = []
    
    public internal(set) var states: [StateID: StateModel.ID] = [:]
    public internal(set) var actions: [ActionID: ActionModel.ID] = [:]
    public internal(set) var flows: [FlowID: FlowModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func createChildObject() async  {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.objectModelIsDeleted)
            logger.failure("ObjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        let systemModelRef = self.owner.ref!
        
        // mutate
        let childObjectModelRef = ObjectModel(owner: self.owner,
                                              role: .node,
                                              parent: self.target)
        systemModelRef.objects[childObjectModelRef.target] = childObjectModelRef.id
        self.childs.insert(childObjectModelRef.target)
    }
    
    public func createNewState() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.objectModelIsDeleted)
            logger.failure("ObjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        // mutate
        let stateModelRef = StateModel(owner: self.id)
        self.states[stateModelRef.target] = stateModelRef.id
    }
    public func createNewAction() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.objectModelIsDeleted)
            logger.failure("ObjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        // mutate
        let actionModelRef = ActionModel(owner: self.id)
        self.actions[actionModelRef.target] = actionModelRef.id
    }
    
    public func removeObject() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.objectModelIsDeleted)
            logger.failure("ObjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        let systemModelRef = self.owner.ref!
        
        // mutate
        cleanUpStateModels(self)
        cleanUpActionModels(self)
        cleanUpChildObjectModel(systemModelRef, self)
        
        if self.role == .root {
            systemModelRef.root = nil
        }
        systemModelRef.objects[self.target] = nil
        self.delete()
    }
    
    
    // MARK: helpher
    private func cleanUpActionModels(_ objectModelRef: ObjectModel) {
        objectModelRef.actions.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
    }
    private func cleanUpStateModels(_ objectModelRef: ObjectModel) {
        objectModelRef.states.values
            .compactMap { $0.ref }
            .forEach {
                $0.getters.values
                    .compactMap { $0.ref }
                    .forEach { $0.delete() }
                
                $0.setters.values
                    .compactMap { $0.ref }
                    .forEach { $0.delete() }
                
                $0.delete()
            }
    }
    private func cleanUpChildObjectModel(_ systemModelRef: SystemModel,
                                         _ objectModelRef: ObjectModel) {
        
        objectModelRef.childs
            .compactMap { systemModelRef.objects[$0]?.ref }
            .forEach { childObjectModelRef in
                cleanUpChildObjectModel(systemModelRef, childObjectModelRef)
                
                cleanUpActionModels(childObjectModelRef)
                cleanUpStateModels(childObjectModelRef)
                childObjectModelRef.delete()
            }
    }
    
    
    
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
    
    public enum Error: String, Swift.Error {
        case objectModelIsDeleted
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
