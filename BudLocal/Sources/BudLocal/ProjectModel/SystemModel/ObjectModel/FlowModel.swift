//
//  FlowModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import ValueSuite

private let logger = BudLogger("FlowModel")


// MARK: Object
@MainActor @Observable
public final class FlowModel: Sendable {
    // MARK: core
    init(owner: ObjectModel.ID, action: ActionID) {
        self.owner = owner
        self.action = action
        
        FlowModelManager.register(self)
    }
    func delete() {
        FlowModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    public nonisolated let owner: ObjectModel.ID
    public nonisolated let target = FlowID()
    
    internal nonisolated let createdAt: Date = .now
    public var updatedAt: Date = .now
    public var order: Int = 0
    
    public var name: String = "New Flow"
    
    public var setters: [SetterID] = []
    public nonisolated let action: ActionID
    
    
    // MARK: action
    public func removeFlow() async {
        fatalError()
    }
    
    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value = UUID()
        nonisolated init() { }
        
        public var isExist: Bool {
            FlowModelManager.container[self] != nil
        }
        public var ref: FlowModel? {
            FlowModelManager.container[self]
        }
    }
}


// MARK: ObjectManaager
@MainActor @Observable
fileprivate final class FlowModelManager: Sendable {
    static var container: [FlowModel.ID: FlowModel] = [:]
    static func register(_ object: FlowModel) {
        container[object.id] = object
    }
    static func unregister(_ id: FlowModel.ID) {
        container[id] = nil
    }
}

