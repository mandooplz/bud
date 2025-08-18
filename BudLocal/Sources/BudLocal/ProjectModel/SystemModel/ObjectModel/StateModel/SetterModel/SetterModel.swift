//
//  SetterModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("SetterModel")


// MARK: Object
@MainActor @Observable
public final class SetterModel: Debuggable, Hookable {
    // MARK: core
    init(owner: StateModel.ID) {
        self.owner = owner
        
        SetterModelManager.register(self)
    }
    func delete() {
        SetterModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: StateModel.ID
    public nonisolated let target = SetterID()
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New Setter"
    public var parameters: [ParameterValue] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func removeSetter() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.setterModelIsDeleted)
            logger.failure("SetterModel이 존재하지 않아 삭제할 수 없습니다.")
            return
        }
        let stateModelRef = self.owner.ref!
        
        // mutate
        removeSetterInAllFlows(self)
        
        stateModelRef.setters[self.target] = nil
        self.delete()
    }
    
    
    // MARK: helpher
    private func removeSetterInAllFlows(_ setterModelRef: SetterModel) {
        
        let stateModelRef = setterModelRef.owner.ref!
        let objectModelRef = stateModelRef.owner.ref!
        let systemModelRef = objectModelRef.owner.ref!
        let projectModelRef = systemModelRef.owner.ref!
        
        
        projectModelRef.systems.values
            .compactMap { $0.ref }
            .flatMap { $0.objects.values }
            .compactMap { $0.ref }
            .flatMap { $0.flows.values }
            .compactMap { $0.ref }
            .forEach {
                $0.setters.removeAll { $0 == setterModelRef.target }
            }
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            SetterModelManager.container[self] != nil
        }
        public var ref: SetterModel? {
            SetterModelManager.container[self]
        }
    }
    
    public enum Error: String, Swift.Error {
        case setterModelIsDeleted
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class SetterModelManager: Sendable {
    static var container: [SetterModel.ID: SetterModel] = [:]
    static func register(_ object: SetterModel) {
        container[object.id] = object
    }
    static func unregister(_ id: SetterModel.ID) {
        container[id] = nil
    }
}


