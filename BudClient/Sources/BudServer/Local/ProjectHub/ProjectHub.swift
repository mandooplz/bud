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
    init(user: UserID) {
        self.user = user
        
        ProjectHubManager.register(self)
    }
    
    
    // MARK: state
    package nonisolated let id = ID()
    nonisolated let user: UserID
    
    var projectSources: [ProjectID: ProjectSource.ID] = [:]
    
    package func registerSync(_ object: ObjectID) async {
        // Firebase에서 자체적으로 처리
        return
    }
    
    var listener: ListenerRegistration?
    var handler: EventHandler?
    package func appendHandler(requester: ObjectID,
                               _ handler: EventHandler) {
        // capture
        guard self.listener == nil else {
            logger.failure("ProjectSource의 Firebase 리스너가 이미 등록되어 있습니다.")
            return
        }
        let me = self.id
        
        // compute
        let db = Firestore.firestore()
        let projectSourcesCollectionRef = db
            .collection(DB.ProjectSources)
            .whereField(ProjectSource.Data.creator, isEqualTo: user.encode())
        
        let projectListener = projectSourcesCollectionRef
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
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
                        if self?.projectSources[diff.target] == nil {
                            logger.notice("ProjectSource가 생성됩니다. - \(data.target)")
                            
                            let projectSourceRef = ProjectSource(
                                id: projectSource,
                                target: data.target,
                                owner: me)
                            
                            self?.projectSources[data.target] = projectSourceRef.id
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
                        if self?.projectSources[data.target] != nil {
                            logger.notice("ProjetSource가 삭제됩니다. - \(data.target)")
                            
                            self?.projectSources[data.target] = nil
                            projectSource.ref?.delete()
                        }
                    }
                }
            }
        
        // mutate
        self.handler = handler
        self.listener = projectListener
    }
    
    package func notifyNameChanged(_ project: ProjectID) async {
        logger.start()
        
        logger.failure("Firebase에서 알아서 처리됨")
    }
    
    // MARK: action
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

