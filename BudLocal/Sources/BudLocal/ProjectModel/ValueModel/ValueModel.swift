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
        
        self.delete()
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

