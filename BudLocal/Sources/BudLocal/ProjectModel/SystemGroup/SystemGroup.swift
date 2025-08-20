//
//  SystemGroup.swift
//  BudLocal
//
//  Created by 김민우 on 8/20/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("SystemGroup")


// MARK: Object
@MainActor @Observable
public final class SystemGroup: Debuggable, Hookable {
    // MARK: core
    init(owner: ProjectModel.ID) {
        self.owner = owner
        
        SystemGroupManager.register(self)
    }
    func delete() {
        SystemGroupManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ProjectModel.ID
    public nonisolated let target = SysGroupID()
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func removeSysGroup() async {
        logger.start()
        
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            SystemGroupManager.container[self] != nil
        }
        public var ref: SystemGroup? {
            SystemGroupManager.container[self]
        }
    }
}


// MARK: ObjectManager
@MainActor @Observable
fileprivate final class SystemGroupManager: Sendable {
    static var container: [SystemGroup.ID: SystemGroup] = [:]
    static func register(_ object: SystemGroup) {
        container[object.id] = object
    }
    static func unregister(_ id: SystemGroup.ID) {
        container[id] = nil
    }
}
