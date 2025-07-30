//
//  ProjectHub.swift
//  BudClient
//
//  Created by 김민우 on 6/30/25.
//
import Foundation
import Values
import Collections
import FirebaseFirestore
import FirebaseAuth

private let logger = BudLogger("ProjectHub")


// MARK: Object
@MainActor
package final class ProjectHub: ProjectHubInterface {
    // MARK: core
    init(user: UserID, owner: BudServer.ID) {
        logger.notice("ProjectSource가 생성됩니다. - \(user)")
        
        self.user = user
        self.owner = owner
        
        ProjectHubManager.register(self)
    }
    
    
    // MARK: state
    package nonisolated let id = ID()
    nonisolated let user: UserID
    nonisolated let owner: BudServer.ID
    
    var projects: [ProjectID: ProjectSource.ID] = [:]
    
    package func registerSync(_ object: ObjectID) async {
        logger.start()
    }
    
    var listener: ListenerRegistration?
    var isListening: Bool = false
    
    var handler: EventHandler?
    
    // MARK: action
    package func appendHandler(requester: ObjectID,
                               _ handler: EventHandler) {
        logger.start()
        
        // capture
        guard isListening == false else {
            logger.failure("유효한 Firebase 리스너가 이미 존재합니다.")
            return
        }
        let me = self.id
        let budServerRef = self.owner.ref!
        
        
        
        // compute
        let db = Firestore.firestore()
        let projectSourcesCollectionRef = db
            .collection(DB.ProjectSources)
            .whereField(ProjectSource.Data.creator, isEqualTo: user.encode())
        
        let projectListener = projectSourcesCollectionRef
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    self?.isListening = false
                    logger.failure(error!)
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    // get ProjectSource
                    let documentId = change.document.documentID
                    let projectSource = ProjectSource.ID(documentId)
                    
                    let data: ProjectSource.Data
                    let diff: ProjectSourceDiff
                    do {
                        data = try change.document.data(as: ProjectSource.Data.self)
                        diff = data.getDiff(id: projectSource)
                    } catch {
                        logger.failure("ProjetSource 디코딩 실패\n\(error)")
                        return
                    }
                    
                    
                    switch change.type {
                    case .added:
                        // create ProjectSource
                        if self?.projects[diff.target] == nil {
                            logger.notice("ProjectSource가 생성됩니다. - \(data.target)")
                            
                            let projectSourceRef = ProjectSource(
                                id: projectSource,
                                target: data.target,
                                owner: me)
                            
                            self?.projects[data.target] = projectSourceRef.id
                        }
                        
                        me.ref?.handler?.execute(.projectAdded(diff))
                    case .modified:
                        // notify
                        logger.notice("ProjectSource가 수정됩니다. - \(data.target)")
                        
                        projectSource.ref?.handlers?.execute(.modified(diff))
                    case .removed:
                        // notify
                        projectSource.ref?.handlers?.execute(.removed)
                        
                        // removed
                        if self?.projects[data.target] != nil {
                            logger.notice("ProjetSource가 삭제됩니다. - \(data.target)")
                            
                            self?.projects[data.target] = nil
                            projectSource.ref?.delete()
                        }
                    }
                }
            }
        
        // mutate
        self.handler = handler
        
        self.listener?.remove()
        self.listener = projectListener
        
        self.isListening = true
        
        budServerRef
            .projectHubs.values
            .compactMap { $0.ref }
            .filter { $0.isListening == false }
            .flatMap { $0.projects.values }
            .compactMap { $0.ref }
            .forEach { cleanUpProjectSource($0) }
    }
    
    package func notifyNameChanged(_ project: ProjectID) async {
        logger.start()
        
        logger.failure("Firebase에서 알아서 처리됨")
    }
    
    package func synchronize() {
        logger.start()
        
        
    }
    
    package func createProject() {
        logger.start()
        
        let db = Firestore.firestore()
        
        do {
            let newProjectName = "Project \(Int.random(in: 1..<1000))"
            
            let data = ProjectSource.Data(name: newProjectName,
                                          creator: self.user)
            
            try db.collection(DB.ProjectSources)
                .addDocument(from: data)
        } catch {
            logger.failure(error)
            return
        }
    }
    
    
    // MARK: Helphers
    private func cleanUpProjectSource(_ projectSourceRef: ProjectSource) {
        // delete Getters
        projectSourceRef.systems.values
            .compactMap { $0.ref }.flatMap { $0.objects.values }
            .compactMap { $0.ref }.flatMap { $0.states.values }
            .compactMap { $0.ref }.flatMap { $0.getters.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        
        // delete Setters
        projectSourceRef.systems.values
            .compactMap { $0.ref }.flatMap { $0.objects.values }
            .compactMap { $0.ref }.flatMap { $0.states.values }
            .compactMap { $0.ref }.flatMap { $0.setters.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete States
        projectSourceRef.systems.values
            .compactMap { $0.ref }.flatMap { $0.objects.values }
            .compactMap { $0.ref }.flatMap { $0.states.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete Actions
        projectSourceRef.systems.values
            .compactMap { $0.ref }.flatMap { $0.objects.values }
            .compactMap { $0.ref }.flatMap { $0.actions.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete Objects
        projectSourceRef.systems.values
            .compactMap { $0.ref }.flatMap { $0.objects.values }
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete Systems
        projectSourceRef.systems.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete Values
        projectSourceRef.values.values
            .compactMap { $0.ref }
            .forEach { $0.delete() }
        
        // delete Project
        projectSourceRef.delete()
    }

    
    
    // MARK: value
    @MainActor
    package struct ID: ProjectHubIdentity {
        let value: UUID = UUID()
        nonisolated init() { }
        
        package var isExist: Bool {
            ProjectHubManager.container[self] != nil
        }
        package var ref: ProjectHub? {
            ProjectHubManager.container[self]
        }
    }
    
    package typealias EventHandler = Handler<ProjectHubEvent>
}


// MARK: ObjectManager
@MainActor
fileprivate final class ProjectHubManager: Sendable {
    // MARK: state
    fileprivate static var container: [ProjectHub.ID: ProjectHub] = [:]
    fileprivate static func register(_ object: ProjectHub) {
        container[object.id] = object
    }
}

