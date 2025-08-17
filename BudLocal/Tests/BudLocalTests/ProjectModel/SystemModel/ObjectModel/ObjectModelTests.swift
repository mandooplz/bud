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
            // given
            try await #require(systemModelRef.objects.count == 1)
            try await #require(systemModelRef.root != nil)
            
            try #require(objectModelRef.role == .root)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            await #expect(systemModelRef.root == nil)
        }
        
        @Test func deleteObjectModel() async throws {
            // given
            try await #require(objectModelRef.id.isExist == true)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            await #expect(objectModelRef.id.isExist == false)
        }
        @Test func deleteAllChildObjects() async throws {
            // given
            try await #require(systemModelRef.objects.count == 1)
            
            await objectModelRef.createChildObject()
            await objectModelRef.createChildObject()
            
            try await #require(systemModelRef.objects.count == 3)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for objectModel in await systemModelRef.objects.values {
                await #expect(objectModel.isExist == false)
            }
        }
        
        @Test func deleteActionModels() async throws {
            // given
            try await #require(objectModelRef.actions.count == 0)
            
            await objectModelRef.createNewAction()
            await objectModelRef.createNewAction()
            await objectModelRef.createNewAction()
            
            try await #require(objectModelRef.actions.count == 3)
            
            // when
            await objectModelRef.removeObject()

            // then
            for actionModel in await objectModelRef.actions.values {
                await #expect(actionModel.isExist == false)
            }
        }
        @Test func deleteActionModelsOfChilds() async throws {
            // given
            let childObjectModelRef = try await createChildObject(objectModelRef)
            
            try await #require(childObjectModelRef.actions.count == 0)
            
            await childObjectModelRef.createNewAction()
            await childObjectModelRef.createNewAction()
            
            try await #require(childObjectModelRef.actions.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for actionModelInChild in await childObjectModelRef.actions.values {
                await #expect(actionModelInChild.isExist == false)
            }
            
        }
        
        @Test func deleteStateModels() async throws {
            // given
            try await #require(objectModelRef.states.count == 0)
            
            await objectModelRef.createNewState()
            await objectModelRef.createNewState()
            
            try await #require(objectModelRef.states.count == 2)
            
            let stateModels = await objectModelRef.states.values
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for stateModel in stateModels {
                await #expect(stateModel.isExist == false)
            }
        }
        @Test func deleteStateModelsOfChilds() async throws {
            // given
            let childObjectModelRef = try await createChildObject(objectModelRef)
            
            try await #require(childObjectModelRef.states.count == 0)
            
            await childObjectModelRef.createNewState()
            await childObjectModelRef.createNewState()
            
            let stateModels = await childObjectModelRef.states.values
            try #require(stateModels.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for stateModel in stateModels {
                await #expect(stateModel.isExist == false)
            }
        }
        
        @Test func deleteGetterModels() async throws {
            // given
            let stateModelRef = try await createState(objectModelRef)
            
            try await #require(stateModelRef.getters.count == 0)
            
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            
            let getterModels = await stateModelRef.getters.values
            try #require(getterModels.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for getterModel in getterModels {
                await #expect(getterModel.isExist == false)
            }
        }
        @Test func deleteGetterModelsOfChilds() async throws {
            // given
            let childObjectModelRef = try await createChildObject(objectModelRef)
            let stateModelRef = try await createState(childObjectModelRef)
            
            try await #require(stateModelRef.getters.count == 0)
            
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            
            let getterModels = await stateModelRef.getters.values
            try #require(getterModels.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for getterModel in getterModels {
                await #expect(getterModel.isExist == false)
            }
        }
        
        @Test func deleteSetterModels() async throws {
            // given
            let stateModelRef = try await createState(objectModelRef)
            
            try await #require(stateModelRef.setters.count == 0)
            
            await stateModelRef.createSetter()
            await stateModelRef.createSetter()
            
            let setterModels = await stateModelRef.setters.values
            try #require(setterModels.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for setterModel in setterModels {
                await #expect(setterModel.isExist == false)
            }
        }
        @Test func deleteSetterModelsOfChilds() async throws {
            // given
            let childObjectModelRef = try await createChildObject(objectModelRef)
            let stateModelRef = try await createState(childObjectModelRef)
            
            try await #require(stateModelRef.setters.count == 0)
            
            await stateModelRef.createSetter()
            await stateModelRef.createSetter()
            
            let setterModels = await stateModelRef.setters.values
            try #require(setterModels.count == 2)
            
            // when
            await objectModelRef.removeObject()
            
            // then
            for setterModel in setterModels {
                await #expect(setterModel.isExist == false)
            }
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
    
    // create ObjectModel
    try await #require(systemModelRef.objects.isEmpty)
    
    await systemModelRef.createRootObject()
    
    try await #require(systemModelRef.objects.count == 1)
    
    let rootObjectModel = try #require(await systemModelRef.root)
    let rootobjectModelRef = try #require(await rootObjectModel.ref)
    return rootobjectModelRef
}

private func createChildObject(_ objectModelRef: ObjectModel) async throws -> ObjectModel {
    let systemModelRef = try #require(await objectModelRef.owner.ref)
    
    try await #require(objectModelRef.childs.count == 0)
    await objectModelRef.createChildObject()
    try await #require(objectModelRef.childs.count == 1)
    
    let childObject = try #require(await objectModelRef.childs.first)
    let childObjectModelRef = try #require(await systemModelRef.objects[childObject]?.ref)
    return childObjectModelRef
}

private func createState(_ objectModelRef: ObjectModel) async throws -> StateModel {
    try await #require(objectModelRef.states.count == 0)
    await objectModelRef.createNewState()
    try await #require(objectModelRef.states.count == 1)
    
    let stateModel = try #require(await objectModelRef.states.values.first)
    let stateModelRef = try #require(await stateModel.ref)
    return stateModelRef
}
