//
//  FlowModel.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation


// MARK: Object
@MainActor @Observable
public final class FlowModel: Sendable {
    // MARK: core
    init() {
        FlowModelManager.register(self)
    }
    func delete() {
        FlowModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    
    
    // MARK: action
    
    
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

