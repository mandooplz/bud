//
//  ProjectModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("ProjectModel")


// MARK: Object
@MainActor @Observable
public final class ProjectModel: Debuggable, Hookable {
    // MARK: core
    init(owner: BudLocal.ID) {
        self.owner = owner
        
        ProjectModelManager.register(self)
    }
    func delete() {
        ProjectModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: BudLocal.ID
    public nonisolated let target = ProjectID()
    
    public var name: String = "New Project"
    
    public var systems: [SystemID: SystemModel.ID] = [:]
    public var values: [ValueID: ValueModel.ID] = [:]
    internal func getSystemModel(_ location: Location) -> SystemModel.ID? {
        self.systems.values
            .first { $0.ref?.location == location }
    }
    internal func isLocationExist(_ location: Location) -> Bool {
        self.systems.values
            .compactMap { $0.ref }
            .contains { $0.location == location }
    }
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func createFirstSystem() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        guard systems.isEmpty else {
            setIssue(Error.systemAlreadyExist)
            logger.failure("첫 번째 시스템이 이미 존재합니다.")
            return
        }
        
        let systemModelRef = SystemModel(owner: self.id,
                                         location: .origin,
                                         role: .local)
        self.systems[systemModelRef.target] = systemModelRef.id
    }
    public func createValue() async {
        logger.start()
        
        // mutate
        await mutateHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        
        let valueModelRef = ValueModel(owner: self.id)
        self.values[valueModelRef.target] = valueModelRef.id
        
    }
    
    public func removeProject() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행취소됩니다.")
            return
        }
        let budLocalRef = self.owner.ref!
        
        // mutate
        self.systems.values
            .compactMap { $0.ref }
            .forEach(cleanUpSystemModel)
        
        self.values.values
            .forEach { $0.ref?.delete() }
        
        budLocalRef.projects[self.target] = nil
        self.delete()
    }
    
    
    // MARK: helpher
    private func cleanUpSystemModel(_ systemModelRef: SystemModel) {
        systemModelRef.objects.values
            .compactMap { $0.ref }
            .forEach(cleanUpObjectModel)
        
        systemModelRef.delete()
    }
    private func cleanUpObjectModel(_ objectModelRef: ObjectModel) {
        // delete GetterModel
        objectModelRef.states.values
            .compactMap { $0.ref }
            .flatMap { $0.getters.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete SetterModel
        objectModelRef.states.values
            .compactMap { $0.ref }
            .flatMap { $0.setters.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete StateModel
        objectModelRef.states.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        
        // delete ActioModel
        objectModelRef.actions.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        
        // delete FlowModel
        objectModelRef.flows.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        
        // delete ObjectModel
        objectModelRef.delete()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            ProjectModelManager.container[self] != nil
        }
        public var ref: ProjectModel? {
            ProjectModelManager.container[self]
        }
    }
    
    public enum Error: String, Swift.Error {
        case projectModelIsDeleted
        case systemAlreadyExist
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class ProjectModelManager {
    static var container: [ProjectModel.ID: ProjectModel] = [:]
    static func register(_ object: ProjectModel) {
        container[object.id] = object
    }
    static func unregister(_ id: ProjectModel.ID) {
        container[id] = nil
    }
}
