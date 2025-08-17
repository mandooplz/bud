//
//  GetterModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("GetterModel")


// MARK: Object
@MainActor @Observable
public final class GetterModel: Debuggable, Hookable {
    // MARK: core
    init(owner: StateModel.ID) {
        self.owner = owner
        
        GetterModelManager.register(self)
    }
    func delete() {
        GetterModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: StateModel.ID
    public nonisolated let target = GetterID()
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New Getter"
    public var parameters: [ParameterValue] = []
    public var result: ValueID?
    
    public var issue: (any IssueRepresentable)?
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func duplicate() async {
        fatalError()
    }
    
    public func removeGetter() async {
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            GetterModelManager.container[self] != nil
        }
        public var ref: GetterModel? {
            GetterModelManager.container[self]
        }
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class GetterModelManager: Sendable {
    static var container: [GetterModel.ID: GetterModel] = [:]
    static func register(_ object: GetterModel) {
        container[object.id] = object
    }
    static func unregister(_ id: GetterModel.ID) {
        container[id] = nil
    }
}


