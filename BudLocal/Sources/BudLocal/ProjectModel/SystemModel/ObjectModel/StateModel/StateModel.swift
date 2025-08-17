//
//  StateModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("StateModel")


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
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
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
    public func createGetter() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.stateModelIsDeleted)
            logger.failure("StateModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        // mutate
        let getterModelRef = GetterModel(owner: self.id)
        self.getters[getterModelRef.target] = getterModelRef.id
    }
    public func createSetter() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.stateModelIsDeleted)
            logger.failure("StateModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        // mutate
        let setterModelRef = SetterModel(owner: self.id)
        self.setters[setterModelRef.target] = setterModelRef.id
    }
    
    public func removeState() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.stateModelIsDeleted)
            logger.failure("StateModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        // mutate
        self.getters.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        self.setters.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        self.delete()
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
    
    public enum Error: String, Swift.Error {
        case stateModelIsDeleted
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

