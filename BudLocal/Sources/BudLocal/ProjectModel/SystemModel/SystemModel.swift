//
//  SystemModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("SystemModel")


// MARK: Object
@MainActor @Observable
public final class SystemModel: Debuggable, Hookable {
    // MARK: core
    init(owner: ProjectModel.ID, location: Location) {
        self.owner = owner
        self.location = location
        
        SystemModelManager.register(self)
    }
    func delete() {
        SystemModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ProjectModel.ID
    public nonisolated let target = SystemID()
    
    public nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New System"
    public var location: Location
    
    public var root: ObjectModel.ID?
    public var objects: [ObjectID: ObjectModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func addSystemRight() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    public func addSystemLeft() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    public func addSystemTop() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    public func addSystemBottom() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    
    public func createRootObject() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    
    public func removeSystem() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.systemModelIsDeleted)
            logger.failure("SystemModel이 존재하지 않아 실행취소됩니다.")
            return
        }
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            SystemModelManager.container[self] != nil
        }
        public var ref: SystemModel? {
            SystemModelManager.container[self]
        }
    }
    public enum Error: String, Swift.Error {
        case systemModelIsDeleted
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class SystemModelManager: Sendable {
    static var container: [SystemModel.ID: SystemModel] = [:]
    static func register(_ object: SystemModel) {
        container[object.id] = object
    }
    static func unregister(_ id: SystemModel.ID) {
        container[id] = nil
    }
}
