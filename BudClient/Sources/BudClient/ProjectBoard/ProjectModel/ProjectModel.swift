//
//  ProjectModel.swift
//  BudClient
//
//  Created by 김민우 on 7/16/25.
//
import Foundation
import Values
import BudServer

private let logger = BudLogger("ProjectModel")


// MARK: Object
@MainActor @Observable
public final class ProjectModel: Debuggable, EventDebuggable, Hookable {
    // MARK: core
    init(config: Config<ProjectBoard.ID>,
         diff: ProjectSourceDiff) {
        logger.notice("ProjectModel이 생성됩니다.")
        
        self.config = config
        self.target = diff.target
        self.source = diff.id
        self.updaterRef = Updater(owner: self.id)
        
        self.name = diff.name
        self.nameInput = diff.name
        
        ProjectModelManager.register(self)
    }
    func delete() {
        logger.notice("ProjectModel이 삭제됩니다.")
        
        ProjectModelManager.unregister(self.id)
    }
    
    
    // MARK: state
    public nonisolated let id = ID()
    nonisolated let config: Config<ProjectBoard.ID>
    nonisolated let updaterRef: Updater
    var isUpdating: Bool = false
    
    nonisolated let target: ProjectID
    nonisolated let source: any ProjectSourceIdentity
    
    public internal(set) var name: String
    public var nameInput: String
    
    var systems: [SystemID: SystemModel.ID] = [:]
    public var systemList: [SystemModel.ID] {
        systems.values
            .sorted {
                ($0.ref!.updatedAt, $0.ref!.order) < ($1.ref!.updatedAt, $1.ref!.order)
            }
    }
    public var systemLocations: [Location] {
        self.systems.values
            .compactMap { $0.ref }
            .map { $0.location }
    }
    
    var values: [ValueID: ValueModel.ID] = [:]
    public var valueList: [ValueModel.ID] {
        self.values.values
            .sorted {
                ($0.ref!.updatedAt, $0.ref!.order) < ($1.ref!.updatedAt, $1.ref!.order)
            }
    }
    
    var workflows: [WorkflowID: WorkflowModel.ID] = [:]
    public var workflowList: [WorkflowModel.ID] {
        self.workflows.values
            .sorted {
                ($0.ref!.updatedAt, $0.ref!.order) < ($1.ref!.updatedAt, $1.ref!.order)
            }
    }
        
    public var issue: (any IssueRepresentable)?
    public var callback: Callback?
    
    package var captureHook: Hook?
    package var computeHook: Hook?
    package var mutateHook: Hook?
    
    
    // MARK: action
    public func startUpdating() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard self.id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        guard isUpdating == false else {
            setIssue(Error.alreadyUpdating)
            logger.failure("이미 updating 중입니다.")
            return
        }
        
        let projectSource = self.source
        let me = ObjectID(self.id.value)
        
        // compute
        await computeHook?()
        await withDiscardingTaskGroup { group in
            group.addTask {
                guard let projectSourceRef = await projectSource.ref else {
                    logger.failure("ProjectSource가 존재하지 않습니다.")
                    return
                }
                
                await projectSourceRef.appendHandler(
                    requester: me,
                    .init({ event in
                        Task { [weak self] in
                            await self?.updaterRef.appendEvent(event)
                            await self?.updaterRef.update()
                            
                            await self?.callback?()
                        }
                    }))
                
                await projectSourceRef.registerSync(me)
                await projectSourceRef.synchronize()
            }
        }
        
        // mutate
        self.isUpdating = true
    }
    public func pushName() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        guard self.nameInput.isEmpty == false else {
            setIssue(Error.nameCannotBeEmpty)
            logger.failure("nameInput이 nil으로 비어있습니다.")
            return
        }
        
        guard self.nameInput != self.name else {
            setIssue(Error.newNameIsSameAsCurrent)
            logger.failure("nameInput과 name이 동일합니다.")
            return
        }
        
        let projectSource = self.source
        let nameInput = self.nameInput
        
        
        // compute
        await computeHook?()
        await withDiscardingTaskGroup { group in
            group.addTask {
                guard let projectSourceRef = await projectSource.ref else {
                    logger.failure("ProjectSouce를 찾을 수 없습니다")
                    return
                }
                
                await projectSourceRef.setName(nameInput)
                await projectSourceRef.notifyStateChanged()
            }
        }
        
        logger.end()
    }
    
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
            setIssue(Error.firstSystemAlreadyExist)
            logger.failure("첫번째 System이 이미 존재합니다.")
            return
        }
        
        // compute
        await withDiscardingTaskGroup { group in
            group.addTask {
                guard let projectSourceRef = await self.source.ref else {
                    logger.failure("ProjectSource가 존재하지 않아 실행 취소됩니다.")
                    return
                }
                
                await projectSourceRef.createSystem()
            }
        }
    }
    public func createValue() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        let source = self.source
        
        // compute
        await withDiscardingTaskGroup { group in
            group.addTask {
                guard let projectSoruceRef = await source.ref else {
                    logger.failure("ProjectSource가 존재하지 않습니다.")
                    return
                }
                
                await projectSoruceRef.createValue()
            }
        }
    }
    
    public func removeProject() async {
        logger.start()
        
        // capture
        await captureHook?()
        guard id.isExist else {
            setIssue(Error.projectModelIsDeleted)
            logger.failure("ProjectModel이 존재하지 않아 실행 취소됩니다.")
            return
        }
        let projectSource = self.source
        
        // compute
        await withDiscardingTaskGroup { group in
            group.addTask {
                guard let projectSourceRef = await projectSource.ref else {
                    logger.failure("ProjectSource가 존재하지 않아 실행 취소됩니다.")
                    return
                }
                
                await projectSourceRef.removeProject()
            }
        }
    }

    
    // MARK: value
    @MainActor
    public struct ID: Sendable, Hashable {
        public let value: UUID
        nonisolated init(value: UUID = UUID()) {
            self.value = value
        }
        
        public var isExist: Bool {
            ProjectModelManager.container[self] != nil
        }
        public var ref: ProjectModel? {
            ProjectModelManager.container[self]
        }
    }
    public enum Error: String, Swift.Error {
        case projectModelIsDeleted
        case alreadyUpdating
        case nameCannotBeEmpty, newNameIsSameAsCurrent
        case firstSystemAlreadyExist
    }
}

// MARK: Object Manager
@MainActor @Observable
fileprivate final class ProjectModelManager: Sendable {
    // MARK: state
    fileprivate static var container: [ProjectModel.ID: ProjectModel] = [:]
    fileprivate static func register(_ object: ProjectModel) {
        container[object.id] = object
    }
    fileprivate static func unregister(_ id: ProjectModel.ID) {
        container[id] = nil
    }
}

