//
//  SystemModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("SystemModel", .timeLimit(.minutes(1)))
struct SystemModelTests {
    struct AddSystemRight {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
            self.projectModelRef = try #require(await systemModelRef.owner.ref)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.addSystemRight()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func appendSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            // when
            await systemModelRef.addSystemRight()
            
            // then
            await #expect(projectModelRef.systems.count == 2)
        }
        @Test func createSystemModelAtRightLocation() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let rightLocation = await systemModelRef.location.getRight()
            
            // when
            await systemModelRef.addSystemRight()
            
            // then
            try await #require(projectModelRef.systems.count == 2)
            
            let newSystemModel = try #require(await projectModelRef.getSystemModel(rightLocation))
            await #expect(newSystemModel.isExist == true)
        }
        
        @Test func setSystemRoleToShared() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let rightLocation = await systemModelRef.location.getRight()
            
            // when
            await systemModelRef.addSystemRight()
            
            // then
            try await #require(projectModelRef.systems.count == 2)
            
            let newSystemModelRef = try #require(await projectModelRef.getSystemModel(rightLocation)?.ref)
            await #expect(newSystemModelRef.role == .shared)
        }
        
        @Test func whenSystemAlreadyExistAtRightLocation() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            await systemModelRef.addSystemRight()
            
            try await #require(projectModelRef.systems.count == 2)
            
            // when
            await systemModelRef.addSystemRight()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemAlreadyExist")
        }
    }
    
    struct AddSystemLeft {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
            self.projectModelRef = try #require(await systemModelRef.owner.ref)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.addSystemLeft()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func appendSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            // when
            await systemModelRef.addSystemLeft()
            
            // then
            await #expect(projectModelRef.systems.count == 2)
        }
        @Test func createSystemModelAtLeftLocation() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let leftLocation = await systemModelRef.location.getLeft()
            
            // when
            await systemModelRef.addSystemLeft()
            
            // then
            let newSystemModel = try #require(await projectModelRef.getSystemModel(leftLocation))
            await #expect(newSystemModel.isExist == true)
        }
        
        @Test func setSystemRoleToShared() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let leftLocation = await systemModelRef.location.getLeft()
            
            // when
            await systemModelRef.addSystemLeft()
            
            // then
            try await #require(projectModelRef.systems.count == 2)
            
            let newSystemModelRef = try #require(await projectModelRef.getSystemModel(leftLocation)?.ref)
            await #expect(newSystemModelRef.role == .shared)
        }
        
        @Test func whenSystemAlreadyExistAtLeftLocation() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            await systemModelRef.addSystemLeft()
            
            try await #require(projectModelRef.systems.count == 2)
            
            // when
            await systemModelRef.addSystemLeft()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemAlreadyExist")
        }
    }
    
    struct AddSystemTop {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
            self.projectModelRef = try #require(await systemModelRef.owner.ref)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.addSystemTop()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func appendSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            // when
            await systemModelRef.addSystemTop()
            
            // then
            await #expect(projectModelRef.systems.count == 2)
        }
        @Test func createSystemModelAtTopLocation() async throws {
            // given
            let topLocation = await systemModelRef.location.getTop()
            
            // when
            await systemModelRef.addSystemTop()
            
            // then
            let newSystemModel = try #require(await projectModelRef.getSystemModel(topLocation))
            await #expect(newSystemModel.isExist == true)
        }
        
        @Test func setSystemRoleToShared() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let topLocation = await systemModelRef.location.getTop()
            
            // when
            await systemModelRef.addSystemTop()
            
            // then
            try await #require(projectModelRef.systems.count == 2)
            
            let newSystemModelRef = try #require(await projectModelRef.getSystemModel(topLocation)?.ref)
            await #expect(newSystemModelRef.role == .shared)
        }
        
        @Test func whenSystemAlreadyExistAtTopLocation() async throws {
            // given
            await systemModelRef.addSystemTop()
            
            // when
            await systemModelRef.addSystemTop()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemAlreadyExist")
        }
    }
    
    struct AddSystemBottom {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
            self.projectModelRef = try #require(await systemModelRef.owner.ref)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.addSystemBottom()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func appendSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            // when
            await systemModelRef.addSystemBottom()
            
            // then
            await #expect(projectModelRef.systems.count == 2)
        }
        @Test func createSystemModelAtTopLocation() async throws {
            // given
            let bottomLocation = await systemModelRef.location.getBotttom()
            
            // when
            await systemModelRef.addSystemBottom()
            
            // then
            let newSystemModel = try #require(await projectModelRef.getSystemModel(bottomLocation))
            await #expect(newSystemModel.isExist == true)
        }
        
        @Test func setSystemRoleToShared() async throws {
            // given
            try await #require(projectModelRef.systems.count == 1)
            
            let bottomLocation = await systemModelRef.location.getBotttom()
            
            // when
            await systemModelRef.addSystemBottom()
            
            // then
            try await #require(projectModelRef.systems.count == 2)
            
            let newSystemModelRef = try #require(await projectModelRef.getSystemModel(bottomLocation)?.ref)
            await #expect(newSystemModelRef.role == .shared)
        }
        
        @Test func whenSystemAlreadyExistAtTopLocation() async throws {
            // given
            await systemModelRef.addSystemBottom()
            
            // when
            await systemModelRef.addSystemBottom()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemAlreadyExist")
        }
    }
    
    struct CreateRootObject {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.createRootObject()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func setRoot() async throws {
            // given
            try await #require(systemModelRef.root == nil)
            
            // when
            await systemModelRef.createRootObject()
            
            // then
            try await #require(systemModelRef.issue == nil)
            
            await #expect(systemModelRef.root != nil)
        }
        @Test func appendObjectModelInObjects() async throws {
            // given
            try await #require(systemModelRef.objects.isEmpty)
            
            // when
            await systemModelRef.createRootObject()
            
            // then
            await #expect(systemModelRef.objects.count == 1)
        }
        @Test func createObjectModel() async throws {
            // given
            try await #require(systemModelRef.objects.isEmpty)
            
            // when
            await systemModelRef.createRootObject()
            
            // then
            let newObjectModel = try #require(await systemModelRef.objects.values.first)
            await #expect(newObjectModel.isExist == true)
        }
        
        @Test func whenRootObjectModelAlreadyExist() async throws {
            // given
            await systemModelRef.createRootObject()
            
            try await #require(systemModelRef.isIssueOccurred == false)
            
            // when
            await systemModelRef.createRootObject()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "rootObjectModelAlreadyExist")
            
        }
    }
    
    struct RemoveSystem {
        let budLocalRef: BudLocal
        let systemModelRef: SystemModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.systemModelRef = try await getSystemModel(budLocalRef)
        }
        
        @Test func whenSystemModelIsDeleted() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            await systemModelRef.setCaptureHook {
                await systemModelRef.delete()
            }
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
        
        @Test func removeSystemModel_ProjectModel() async throws {
            // given
            let system = systemModelRef.target
            
            let projectModelRef = try #require(await systemModelRef.owner.ref)
            try await #require(projectModelRef.systems[system] != nil)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(projectModelRef.systems[system] == nil)
        }
        @Test func deleteSystemModel() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(systemModelRef.id.isExist == false)
        }
        @Test func deleteObjectModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await #require(objectModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(objectModelRef.id.isExist == false)
        }
        @Test func deleteStateModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            
            try await #require(stateModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(stateModelRef.id.isExist == false)
        }
        @Test func deleteGetterModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            let getterModelRef = try await createGetterModel(stateModelRef)
            
            try await #require(getterModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(getterModelRef.id.isExist == false)
        }
        @Test func deleteSetterModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            let setterModelRef = try await createSetterModel(stateModelRef)
            
            try await #require(setterModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(setterModelRef.id.isExist == false)
        }
        @Test func deleteActionModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let actionModelRef = try await createActionModel(objectModelRef)
            
            try await #require(actionModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(actionModelRef.id.isExist == false)
        }
        @Test func deleteFlowModels() async throws {
            // given
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let actionModelRef = try await createActionModel(objectModelRef)
            let flowModelRef = try await createFlowModel(actionModelRef)
            
            try await #require(flowModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(flowModelRef.id.isExist == false)
        }
    }
}


// MARK: Helphers
private func getSystemModel(_ budLocalRef: BudLocal) async throws -> SystemModel {
    // createProjectModel
    try await #require(budLocalRef.projects.isEmpty)
    
    await budLocalRef.createProject()
    
    let projectModel = try #require(await budLocalRef.projects.values.first)
    let projectModelRef = try #require(await projectModel.ref)
    
    // create SystemModel
    try await #require(projectModelRef.systems.isEmpty)
    
    await projectModelRef.createFirstSystem()
    
    try await #require(projectModelRef.systems.count == 1)
    
    // return
    let systemModel = try #require(await projectModelRef.systems.values.first)
    let systemModelRef = try #require(await systemModel.ref)
    return systemModelRef
}

private func createRootObjectModel(_ systemModelRef: SystemModel) async throws -> ObjectModel {
    try await #require(systemModelRef.objects.count == 0)
    
    await systemModelRef.createRootObject()
    
    try await #require(systemModelRef.objects.count == 1)
    
    let rootObjectModel = try #require(await systemModelRef.root)
    let rootObjectModelRef = try #require(await rootObjectModel.ref)
    return rootObjectModelRef
}

private func createStateModel(_ objectModelRef: ObjectModel) async throws -> StateModel {
    try await #require(objectModelRef.states.count == 0)
    
    await objectModelRef.createNewState()
    
    try await #require(objectModelRef.states.count == 1)
    
    let stateModel = try #require(await objectModelRef.states.values.first)
    let stateModelRef = try #require(await stateModel.ref)
    return stateModelRef
}

private func createGetterModel(_ stateModelRef: StateModel) async throws -> GetterModel {
    try await #require(stateModelRef.getters.count == 0)
    await stateModelRef.createGetter()
    try await #require(stateModelRef.getters.count == 1)
    
    let getterModel = try #require(await stateModelRef.getters.values.first)
    let getterModelRef = try #require(await getterModel.ref)
    return getterModelRef
}

private func createSetterModel(_ stateModelRef: StateModel) async throws -> SetterModel {
    try await #require(stateModelRef.setters.count == 0)
    await stateModelRef.createSetter()
    try await #require(stateModelRef.setters.count == 1)
    
    let setterModel = try #require(await stateModelRef.setters.values.first)
    let setterModelRef = try #require(await setterModel.ref)
    return setterModelRef
}

private func createActionModel(_ objectModelRef: ObjectModel) async throws -> ActionModel {
    try await #require(objectModelRef.actions.count == 0)
    
    await objectModelRef.createNewAction()
    
    try await #require(objectModelRef.actions.count == 1)
    
    let actionModel = try #require(await objectModelRef.actions.values.first)
    let actionModelRef = try #require(await actionModel.ref)
    return actionModelRef
}

private func createFlowModel(_ actionModelRef: ActionModel) async throws -> FlowModel {
    let objectModelRef = try #require(await actionModelRef.owner.ref)
    
    try await #require(objectModelRef.flows.count == 0)
    
    await actionModelRef.createFlow()
    
    try await #require(objectModelRef.flows.count == 1)
    
    let flowModel = try #require(await objectModelRef.flows.values.first)
    let flowModelRef = try #require(await flowModel.ref)
    return flowModelRef
}
