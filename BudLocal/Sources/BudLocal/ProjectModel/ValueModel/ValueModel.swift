//
//  ValueModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("ValueModel")


// MARK: Object
@MainActor @Observable
public final class ValueModel: Debuggable, Hookable {
    // MARK: core
    init(owner: ProjectModel.ID) {
        self.owner = owner
        
        ValueModelManager.register(self)
    }
    func delete() {
        ValueModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ProjectModel.ID
    public nonisolated let target = ValueID()
    
    public nonisolated let createdAt = Date.now
    public internal(set) var updatedAt = Date.now
    public internal(set) var order = 0
    
    public var name: String = "New Value"
    public var description: String?
    public var fields: [ValueField] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func removeValue() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.valueModelIsDeleted)
            logger.failure("ValueModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        let projectModelRef = self.owner.ref!
        
        // mutate
        updateTypeOfValues(self)
        
        projectModelRef.values[self.target] = nil
        self.delete()
    }
    
    
    // MARK: helpher
    private func updateTypeOfValues(_ valueModelRef: ValueModel) {
        let valueType = valueModelRef.target
        let projectModelRef = valueModelRef.owner.ref!
        
        // update StateModel.stateValue
        let stateModels = projectModelRef.systems.values
            .compactMap { systemModel in systemModel.ref }
            .flatMap { $0.objects.values }
            .compactMap { objectModel in objectModel.ref }
            .flatMap { $0.states.values }
        
        stateModels
            .compactMap { $0.ref }
            .filter { $0.stateValue?.type == valueType }
            .forEach {
                let newValue = $0.stateValue?.setType(nil)
                $0.stateValue = newValue
            }
        
        // update GetterModel.parameters & parameterInput
        let getterModels = stateModels
            .compactMap { $0.ref }
            .flatMap { $0.getters.values }
        
        getterModels
            .compactMap { $0.ref }
            .forEach { getterModelRef in
                getterModelRef.parameters
                    .enumerated()
                    .filter { $0.element.type == valueType }
                    .forEach { (index, parameterValue) in
                        let newValue = parameterValue.setType(nil)
                        
                        getterModelRef.parameters[index] = newValue
                    }
            }
        
        // update GetterModel.result & resultInput
        getterModels
            .compactMap { $0.ref }
            .forEach { getterModelRef in
                getterModelRef.result = nil
            }
        
        
        // update SetterModel.parameters & parameterInput
        let setterModels = stateModels
            .compactMap { $0.ref }
            .flatMap { $0.setters.values }
        
        setterModels
            .compactMap { $0.ref }
            .forEach { setterModelRef in
                setterModelRef.parameters
                    .enumerated()
                    .filter { $0.element.type == valueType }
                    .forEach { (index, parameterValue) in
                        let newValue = parameterValue.setType(nil)
                        
                        setterModelRef.parameters[index] = newValue
                    }
            }
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            ValueModelManager.container[self] != nil
        }
        public var ref: ValueModel? {
            ValueModelManager.container[self]
        }
    }
    public enum Error: String, Swift.Error {
        case valueModelIsDeleted
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class ValueModelManager: Sendable {
    static var container: [ValueModel.ID: ValueModel] = [:]
    static func register(_ object: ValueModel) {
        container[object.id] = object
    }
    static func unregister(_ id: ValueModel.ID) {
        container[id] = nil
    }
}

