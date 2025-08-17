//
//  ObjectModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("ObjectModel", .timeLimit(.minutes(1)))
struct ObjectModelTests {
    struct CreateChildObject {
        let budLocalRef: BudLocal
        let objectModelRef: ObjectModel
        let systemModelRef: SystemModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.objectModelRef = try await getObjectModel(budLocalRef)
            self.systemModelRef = try #require(await objectModelRef.owner.ref)
        }
        
        @Test func whenObjectModelIsDeleted() async throws {
            // given
            try await #require(objectModelRef.id.isExist == true)
            
            await objectModelRef.setCaptureHook {
                await objectModelRef.delete()
            }
            
            // when
            await objectModelRef.createChildObject()
            
            // then
            let issue = try #require(await objectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "objectModelIsDeleted")
        }
        
        @Test func appendObjectModel_SystemModel() async throws {
            // given
            let count = await systemModelRef.objects.count
            
            // when
            await objectModelRef.createChildObject()
            
            // then
            await #expect(systemModelRef.objects.count == count + 1)
        }
        @Test func createObjectModel_SystemModel() async throws {
            // given
            try await #require(systemModelRef.objects.count == 1)
            
            try #require(objectModelRef.role == .root)
            
            // when
            await objectModelRef.createChildObject()
            
            // then
            try await #require(systemModelRef.objects.count == 2)
            
            let newObjectModel = try #require(await systemModelRef.recentObject)
            
            await #expect(newObjectModel.isExist == true)
        }
        @Test func setNewObjectModelParentToSelfTarget() async throws {
            // given
            try await #require(systemModelRef.objects.count == 1)
            
            try #require(objectModelRef.role == .root)
            
            // when
            await objectModelRef.createChildObject()
            
            // then
            try await #require(systemModelRef.objects.count == 2)
            
            let newObjectModelRef = try #require(await systemModelRef.recentObject?.ref)
            
            await #expect(newObjectModelRef.parent == objectModelRef.target)
        }
        @Test func appendNewObjectModelTargetInChilds() async throws {
            // given
            try await #require(systemModelRef.objects.count == 1)
            
            try #require(objectModelRef.role == .root)
            try await #require(objectModelRef.childs.count == 0)
            
            // when
            await objectModelRef.createChildObject()
            
            // then
            try await #require(systemModelRef.objects.count == 2)
            

            let childObjectModel = try #require(await systemModelRef.recentObject)
            let newObject = try #require(await childObjectModel.ref?.target)
            
            try await #require(objectModelRef.childs.count == 1)
            await #expect(objectModelRef.childs.first == newObject)
        }
    }
    
    struct CreateNewState {
        let budLocalRef: BudLocal
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.objectModelRef = try await getObjectModel(budLocalRef)
        }
        
        @Test func whenObjectModelIsDeleted() async throws {
            // given
            try await #require(objectModelRef.id.isExist == true)
            
            await objectModelRef.setCaptureHook {
                await objectModelRef.delete()
            }
            
            // when
            await objectModelRef.createNewState()
            
            // then
            let issue = try #require(await objectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "objectModelIsDeleted")
        }
        
        @Test func appendStateModel() async throws {
            // given
            try await #require(objectModelRef.states.isEmpty)
            
            // when
            await objectModelRef.createNewState()
            
            // then
            await #expect(objectModelRef.states.count == 1)
        }
        @Test func createStateModel() async throws {
            // given
            try await #require(objectModelRef.states.isEmpty)
            
            // when
            await objectModelRef.createNewState()
            
            // then
            let stateModel = try #require(await objectModelRef.states.values.first)
            await #expect(stateModel.isExist == true)
        }
    }
    
    struct CreateNewAction {
        let budLocalRef: BudLocal
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.objectModelRef = try await getObjectModel(budLocalRef)
        }
        
        @Test func whenObjectModelIsDeleted() async throws {
            // given
            try await #require(objectModelRef.id.isExist == true)
            
            await objectModelRef.setCaptureHook {
                await objectModelRef.delete()
            }
            
            // when
            await objectModelRef.createNewAction()
            
            // then
            let issue = try #require(await objectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "objectModelIsDeleted")
        }
        
        @Test func appendActionModel() async throws {
            // given
            try await #require(objectModelRef.actions.isEmpty)
            
            // when
            await objectModelRef.createNewAction()
            
            // then
            await #expect(objectModelRef.actions.count == 1)
        }
        @Test func createActionModel() async throws {
            // given
            try await #require(objectModelRef.actions.isEmpty)
            
            // when
            await objectModelRef.createNewAction()
            
            // then
            let actionModel = try #require(await objectModelRef.actions.values.first)
            await #expect(actionModel.isExist == true)
        }
    }
    
    struct RemoveObject {
        let budLocalRef: BudLocal
        let objectModelRef: ObjectModel
        let systemModelRef: SystemModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.objectModelRef = try await getObjectModel(budLocalRef)
            self.systemModelRef = try #require(await objectModelRef.owner.ref)
        }
        
        @Test func whenObjectModelIsDeleted() async throws {
            // given
            try await #require(objectModelRef.id.isExist == true)
            
            await objectModelRef.setCaptureHook {
                await objectModelRef.delete()
            }
            
            // when
            await objectModelRef.removeObject()
            
            // then
            let issue = try #require(await objectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "objectModelIsDeleted")
        }
        
        @Test func setRootNilWhenRemoveRootObject_SystemModel() async throws {
            Issue.record("구현 에정")
        }
        
        @Test func deleteObjectModel() async throws {
            
        }
        @Test func deleteAllChildObjects() async throws {
            Issue.record("구현 에정")
        }
        
        @Test func deleteActionModels() async throws {
            Issue.record("구현 에정")
        }
        @Test func deleteStateModels() async throws {
            Issue.record("구현 에정")
        }
        @Test func deleteGetterModels() async throws {
            Issue.record("구현 에정")
        }
        @Test func deleteSetterModels() async throws {
            
        }
    }
}


// MARK: Helphers
private func getObjectModel(_ budLocalRef: BudLocal) async throws -> ObjectModel {
    // create ProjectModel
    try await #require(budLocalRef.projects.isEmpty)
    
    await budLocalRef.createProject()
    
    let projectModel = try #require(await budLocalRef.projects.values.first)
    let projectModelRef = try #require(await projectModel.ref)
    
    // create SystemModel
    try await #require(projectModelRef.systems.isEmpty)
    
    await projectModelRef.createFirstSystem()
    
    try await #require(projectModelRef.systems.count == 1)
    
    let systemModel = try #require(await projectModelRef.systems.values.first)
    let systemModelRef = try #require(await systemModel.ref)
    
    // create ObjectMdel
    try await #require(systemModelRef.objects.isEmpty)
    
    await systemModelRef.createRootObject()
    
    try await #require(systemModelRef.objects.count == 1)
    
    let rootObjectModel = try #require(await systemModelRef.root)
    let rootobjectModelRef = try #require(await rootObjectModel.ref)
    return rootobjectModelRef
}
