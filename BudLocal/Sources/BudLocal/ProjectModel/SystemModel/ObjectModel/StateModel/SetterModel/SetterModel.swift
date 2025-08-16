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
    init() {
        SetterModelManager.register(self)
    }
    func delete() {
        SetterModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let target = SetterID()
    
    public var name: String = "New Setter"
    public var parameters: [ParameterValue] = []
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func duplicateSetter() async {
        fatalError()
    }
    public func removeSetter() async {
        fatalError()
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


