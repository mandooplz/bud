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
    
    public var name: String = "New System"
    public var location: Location
    
    public var root: ObjectModel.ID?
    public var objects: [ObjectID: ObjectModel.ID] = [:]
    public var recentObject: ObjectModel.ID? {
        // 1. 딕셔너리의 모든 ID 값들을 가져옵니다.
        self.objects.values
            // 2. 각 ID를 실제 ObjectModel로 변환합니다.
            //    ref가 nil인 (유효하지 않은) ID는 이 과정에서 자동으로 걸러집니다.
            .compactMap { $0.ref }
            // 3. 유효한 ObjectModel 배열에서 createdAt이 가장 큰 객체를 찾습니다.
            .max { $0.createdAt < $1.createdAt }?
            // 4. 찾은 ObjectModel의 ID를 반환합니다.
            //    만약 찾은 객체가 없다면(배열이 비어있었다면) nil이 됩니다.
            .id
    }
    
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
        let rightLocation = self.location.getRight()
        let projectModelRef = self.owner.ref!
        
        // mutate
        guard projectModelRef.isLocationExist(rightLocation) == false else {
            setIssue(Error.systemAlreadyExist)
            logger.failure("(\(rightLocation.x), \(rightLocation.y)) 위치에 System이 이미 존재합니다.")
            return
        }
        
        let systemModelRef = SystemModel(owner: owner,
                                         location: rightLocation)
        projectModelRef.systems[systemModelRef.target] = systemModelRef.id
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
        let leftLocation = self.location.getLeft()
        let projectModelRef = self.owner.ref!
        
        // mutate
        guard projectModelRef.isLocationExist(leftLocation) == false else {
            setIssue(Error.systemAlreadyExist)
            logger.failure("(\(leftLocation.x), \(leftLocation.y)) 위치에 System이 이미 존재합니다.")
            return
        }
        
        let systemModelRef = SystemModel(owner: owner, location: leftLocation)
        projectModelRef.systems[systemModelRef.target] = systemModelRef.id
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
        let topLocation = location.getTop()
        let projectModelRef = self.owner.ref!
        
        // mutate
        guard projectModelRef.isLocationExist(topLocation) == false else {
            setIssue(Error.systemAlreadyExist)
            logger.failure("(\(topLocation.x), \(topLocation.y)) 위치에 System이 이미 존재합니다.")
            return
        }
        
        let systemModelRef = SystemModel(owner: owner,
                                         location: topLocation)
        projectModelRef.systems[systemModelRef.target] = systemModelRef.id
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
        let bottomLocation = self.location.getBotttom()
        let projectModelRef = self.owner.ref!
        
        // mutate
        guard projectModelRef.isLocationExist(bottomLocation) == false else {
            setIssue(Error.systemAlreadyExist)
            logger.failure("(\(bottomLocation.x), \(bottomLocation.y)) 위치에 System이 이미 존재합니다.")
            return
        }
        let systemModelRef = SystemModel(owner: owner, location: bottomLocation)
        projectModelRef.systems[systemModelRef.target] = systemModelRef.id
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
        guard self.root == nil else {
            setIssue(Error.rootObjectModelAlreadyExist)
            logger.failure("이미 Root에 해당하는 ObjectModel이 존재합니다.")
            return
        }
        
        // mutate
        let objectModelRef = ObjectModel(owner: self.id,
                                         role: .root)
        self.root = objectModelRef.id
        self.objects[objectModelRef.target] = objectModelRef.id
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
        
        // mutate
        self.delete()
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
        case systemAlreadyExist
        case rootObjectModelAlreadyExist
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

