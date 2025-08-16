//
//  ProjectModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/13/25.
//
import Foundation
import ValueSuite


// MARK: Object
@MainActor @Observable
public final class ProjectModel: Debuggable, EventDebuggable, Hookable {
    // MARK: core
    init() {
        ProjectModelManager.register(self)
    }
    func delete() {
        ProjectModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let target = ProjectID()
    
    public var name: String = "New Project"
    public var systems: [SystemID: SystemModel.ID] = [:]
    public var values: [ValueID: ValueModel.ID] = [:]
    
    public var issue: (any IssueRepresentable)?
    public var callback: Callback?
    
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func createFirstSystem() async { }
    public func createValue() async { }
    
    public func removeProject() async { }
    
    
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
