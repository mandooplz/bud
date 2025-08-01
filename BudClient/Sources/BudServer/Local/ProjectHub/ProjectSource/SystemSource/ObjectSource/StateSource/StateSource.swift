//
//  StateSource.swift
//  BudClient
//
//  Created by 김민우 on 7/17/25.
//
import Foundation
import Values
import FirebaseFirestore
import BudMacro

private let logger = BudLogger("StateSource")


// MARK: Object
@MainActor
package final class StateSource: StateSourceInterface {
    // MARK: core
    init(id: ID, target: StateID, owner: ObjectSource.ID) {
        logger.notice("StateSource가 생성됩니다.")
        
        self.id = id
        self.target = target
        self.owner = owner
        
        StateSourceManager.register(self)
    }
    func delete() {
        logger.notice("StateSource가 삭제됩니다.")
        self.listener?.remove()
        
        StateSourceManager.unregister(self.id)
    }
    
    
    // MARK: state
    nonisolated let id: ID
    nonisolated let target: StateID
    nonisolated let owner: ObjectSource.ID
    
    var listener: Listener?
    var isListening: Bool = false
    var handler: EventHandler?
    
    var getters: [GetterID: GetterSource.ID] = [:]
    var setters: [SetterID: SetterSource.ID] = [:]
    
    package func setName(_ value: String) async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let stateSourceDocRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
        
        let updateFields: [String: Any] = [
            StateSource.Data.name: value
        ]
        
        // compute
        do {
            try await stateSourceDocRef.updateData(updateFields)
        } catch {
            logger.failure("StateSource name 업데이트 실패\n\(error)")
            return
        }
    }
    package func setStateValue(_ value: StateValue?) async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let stateSourceDocRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
        
        let updateFields: [String: Any] = { @Sendable in
            if let value {
                return [Data.stateValue: value.encode() ]
            } else {
                return [Data.stateValue: NSNull() ]
            }
        }()
        
        // compute
        do {
            try await stateSourceDocRef.updateData(updateFields)
        } catch {
            logger.failure("StateSource stateValue 업데이트 실패\n\(error)")
            return
        }
    }
    package func setAccessLevel(_ value: AccessLevel) async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다.")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let stateSourceDocRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
        
        let updateFields: [String: Any] = [
            Data.accessLevel: value.rawValue
        ]
        
        // compute
        do {
            try await stateSourceDocRef.updateData(updateFields)
        } catch {
            logger.failure("StateSource accesslevel 업데이트 실패\n\(error)")
            return
        }
    }
    
    package func registerSync(_ object: ObjectID) async {
        logger.start()
    }
    
    
    // MARK: action
    package func appendHandler(requester: ObjectID,
                               _ handler: EventHandler) async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 종료됩니다.")
            return
        }
        guard isListening == false else {
            logger.failure("GetterSource, SetterSource의 유효한 Firebase 리스너가 이미 존재합니다.")
            return
        }
        let me = self.id
        
        let objectSource = self.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let stateSourceDocRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(self.id.value)
        
        // compute
        let getterListener = stateSourceDocRef
            .collection(DB.GetterSources)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    logger.failure("SnapshotListener Error \n\(error!))")
                    self?.isListening = false
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    // get StateSource
                    let documentId = change.document.documentID
                    let getterSource = GetterSource.ID(documentId)
                    
                    // get StateSource.Data
                    let data: GetterSource.Data
                    let diff: GetterSourceDiff
                    do {
                        data = try change.document.data(as: GetterSource.Data.self)
                        diff = data.getDiff(id: getterSource)
                    } catch {
                        logger.failure("GetterSource 디코딩 실패\n\(error)")
                        return
                    }
                    
                    // event
                    switch change.type {
                    case .added:
                        // create StateSource
                        let getterSourceRef = GetterSource(id: getterSource,
                                                         target: diff.target,
                                                         owner: me)
                        me.ref?.getters[diff.target] = getterSourceRef.id
                        
                        // notify
                        me.ref?.handler?.execute(.getterAdded(diff))
                    case .modified:
                        // notify
                        getterSource.ref?.handler?.execute(.modified(diff))
                    case .removed:
                        // notify
                        getterSource.ref?.handler?.execute(.removed)
                        
                        // remove StateSource
                        getterSource.ref?.delete()
                        me.ref?.getters[diff.target] = nil
                    }
                }
            }
        
        let setterListener = stateSourceDocRef
            .collection(DB.SetterSources)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let snapshot else {
                    logger.failure("SnapshotListener Error: \(error!))")
                    self?.isListening = false
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    // get StateSource
                    let documentId = change.document.documentID
                    let setterSource = SetterSource.ID(documentId)
                    
                    // get StateSource.Data
                    let data: SetterSource.Data
                    let diff: SetterSourceDiff
                    do {
                        data = try change.document.data(as: SetterSource.Data.self)
                        diff = data.getDiff(id: setterSource)
                    } catch {
                        logger.failure("GetterSource 디코딩 실패\n\(error)")
                        return
                    }
                    
                    // event
                    switch change.type {
                    case .added:
                        // create StateSource
                        let setterSourceRef = SetterSource(id: setterSource,
                                                           target: diff.target,
                                                           owner: me)
                        me.ref?.setters[diff.target] = setterSourceRef.id
                        
                        // notify
                        me.ref?.handler?.execute(.setterAdded(diff))
                    case .modified:
                        // notify
                        setterSource.ref?.handler?.execute(.modified(diff))
                    case .removed:
                        // notify
                        setterSource.ref?.handler?.execute(.removed)
                        
                        // remove StateSource
                        setterSource.ref?.delete()
                        me.ref?.setters[diff.target] = nil
                    }
                }
            }
        
        // mutate
        self.handler = handler
        
        self.listener?.remove()
        self.listener = .init(getter: getterListener,
                              setter: setterListener)
        
        self.isListening = true
    }
    
    package func synchronize() async {
        logger.start()
    }
    package func notifyStateChanged() async {
        logger.start()
    }
    
    package func appendNewGetter() async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다. ")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let getterSourceCollectionRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
            .collection(DB.GetterSources)
        
        // compute
        let newGetterSourceData = GetterSource.Data()
        
        do {
            try getterSourceCollectionRef.addDocument(from: newGetterSourceData)
        } catch {
            logger.failure("GetterSource 생성 실패\n\(error)")
            return
        }
        
    }
    package func appendNewSetter() async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다. ")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let setterSourceCollectionRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
            .collection(DB.SetterSources)
        
        // compute
        let newSetterSourceData = SetterSource.Data()
        
        do {
            try setterSourceCollectionRef.addDocument(from: newSetterSourceData)
        } catch {
            logger.failure("SetterSource 생성 실패\n\(error)")
            return
        }
        
        
    }
    
    package func duplicateState() async {
        logger.start()
        
        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다. ")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let firebaseDB = Firestore.firestore()
        
        let stateSourceCollectionRef = firebaseDB
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources)
        
        let stateSourceDocRef = stateSourceCollectionRef
            .document(stateSource.value)
        
        // compute
        do {
            let _ = try await firebaseDB.runTransaction { @Sendable transaction, _ in
                // get sourceData
                let sourceData: StateSource.Data
                do {
                    sourceData = try transaction.getDocument(stateSourceDocRef)
                        .data(as: StateSource.Data.self)
                    
                } catch {
                    logger.failure("Get StateSourceData 실패\n\(error)")
                    return
                }
                
                // create StateSource(duplicated)
                let newData = StateSource.Data(
                    name: sourceData.name,
                    accessLevel: sourceData.accessLevel,
                    stateValue: sourceData.stateValue
                )
                
                let newDocRef = stateSourceCollectionRef.document()
                
                do {
                    try transaction.setData(from: newData,
                                                  forDocument: newDocRef)
                } catch {
                    logger.failure("Create StateSource 실패\n\(error)")
                    return
                }
                
                return
            }
        } catch {
            logger.failure(error)
            return
        }
    }
    package func removeState() async {
        logger.start()

        // capture
        guard id.isExist else {
            logger.failure("StateSource가 존재하지 않아 실행 취소됩니다. ")
            return
        }
        
        let stateSource = self.id
        let objectSource = stateSource.ref!.owner
        let systemSource = objectSource.ref!.owner
        let projectSource = systemSource.ref!.owner
        
        let stateSourceDocRef = Firestore.firestore()
            .collection(DB.ProjectSources).document(projectSource.value)
            .collection(DB.SystemSources).document(systemSource.value)
            .collection(DB.ObjectSources).document(objectSource.value)
            .collection(DB.StateSources).document(stateSource.value)
        
        // compute
        do {
            try await stateSourceDocRef.delete()
        } catch {
            logger.failure("StateSource 삭제 실패\n\(error)")
            return
        }
    }
    
    
    
    
    // MARK: value
    package typealias EventHandler = Handler<StateSourceEvent>
    
    @MainActor
    package struct ID: StateSourceIdentity {
        let value: String
        nonisolated init(_ value: String) {
            self.value = value
        }
        
        package var isExist: Bool {
            StateSourceManager.container[self] != nil
        }
        package var ref: StateSource? {
            StateSourceManager.container[self]
        }
    }
    @ShowState
    package struct Data: Codable {
        @DocumentID var id: String?
        package var target: StateID
        
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var updatedAt: Timestamp?
        var order: Int
        
        package var name: String
        package var accessLevel: AccessLevel
        package var stateValue: StateValue?
        
        init(order: Int = 0,
             name: String = "New State",
             accessLevel: AccessLevel = .readAndWrite,
             stateValue: StateValue? = nil) {
            self.order = order
            self.name = name
            self.target = StateID()
            self.accessLevel = accessLevel
            self.stateValue = stateValue
        }
        
        func getDiff(id: StateSource.ID) -> StateSourceDiff {
            let now = Date.now
            
            return .init(
                id: id,
                target: self.target,
                createdAt: createdAt?.dateValue() ?? now,
                updatedAt: updatedAt?.dateValue() ?? now,
                order: self.order,
                name: self.name,
                accessLevel: self.accessLevel,
                stateValue: self.stateValue)
        }
    }
    
    struct Listener {
        let getter: ListenerRegistration
        let setter: ListenerRegistration
        
        func remove() {
            self.getter.remove()
            self.setter.remove()
        }
    }
}


// MARK: ObjectManager
@MainActor
fileprivate final class StateSourceManager: Sendable {
    // MARK: state
    fileprivate static var container: [StateSource.ID: StateSource] = [:]
    fileprivate static func register(_ object: StateSource) {
        container[object.id] = object
    }
    fileprivate static func unregister(_ id: StateSource.ID) {
        container[id] = nil
    }
}
