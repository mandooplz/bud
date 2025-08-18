//
//  ProjectModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("ProjectModel", .timeLimit(.minutes(1)))
struct ProjectModelTests {
    struct CreateFirstSystem {
        let budLocalRef: BudLocal
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.projectModelRef = try await getProjectModel(budLocalRef)
        }
        
        @Test func whenProjectModelIsDeleted() async throws {
            // given
            try await #require(projectModelRef.id.isExist == true)
            
            await projectModelRef.setCaptureHook {
                await projectModelRef.delete()
            }
            // when
            await projectModelRef.createFirstSystem()
            
            // then
            let issue = try #require(await projectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "projectModelIsDeleted")
        }
        
        @Test func appendSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.isEmpty)
            
            // when
            await projectModelRef.createFirstSystem()
            
            // then
            await #expect(projectModelRef.systems.count == 1)
        }
        @Test func createSystemModel() async throws {
            // given
            try await #require(projectModelRef.systems.isEmpty)
            
            // when
            await projectModelRef.createFirstSystem()
            
            // then
            try await #require(projectModelRef.systems.count == 1)
            
            let systemModel = try #require(await projectModelRef.systems.values.first)
            await #expect(systemModel.isExist == true)
        }
        
        @Test func whenSystemAlredayExist() async throws {
            // given
            try await #require(projectModelRef.systems.isEmpty)
            
            await projectModelRef.createFirstSystem()
            
            try await #require(projectModelRef.systems.count == 1)
            try await #require(projectModelRef.isIssueOccurred == false)
            
            // when
            await projectModelRef.createFirstSystem()
            
            // then
            await #expect(projectModelRef.isIssueOccurred == true)
            
            let issue = try #require(await projectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemAlreadyExist")
        }
    }
    
    struct CreateValue {
        let budLocalRef: BudLocal
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.projectModelRef = try await getProjectModel(budLocalRef)
        }
        
        @Test func whenProjectModelIsDeleted() async throws {
            // given
            try await #require(projectModelRef.id.isExist == true)
            
            await projectModelRef.setMutateHook {
                await projectModelRef.delete()
            }
            // when
            await projectModelRef.createValue()
            
            // then
            let issue = try #require(await projectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "projectModelIsDeleted")
        }
        
        @Test func appendValueModel() async throws {
            // given
            try await #require(projectModelRef.values.isEmpty)
            
            // when
            await projectModelRef.createValue()
            
            // then
            try await #require(projectModelRef.isIssueOccurred == false)
            
            await #expect(projectModelRef.values.count == 1)
        }
        @Test func createValueModel() async throws {
            // given
            try await #require(projectModelRef.values.isEmpty)
            
            // when
            await projectModelRef.createValue()
            
            // then
            try await #require(projectModelRef.isIssueOccurred == false)
            
            let valueModel = try #require(await projectModelRef.values.values.first)
            await #expect(valueModel.isExist == true)
        }
    }
    
    struct RemoveProject {
        let budLocalRef: BudLocal
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.projectModelRef = try await getProjectModel(budLocalRef)
        }
        
        @Test func whenProjectModelIsDeleted() async throws {
            // given
            try await #require(projectModelRef.id.isExist == true)
            
            await projectModelRef.setCaptureHook {
                await projectModelRef.delete()
            }
            // when
            await projectModelRef.removeProject()
            
            // then
            let issue = try #require(await projectModelRef.issue as? KnownIssue)
            #expect(issue.reason == "projectModelIsDeleted")
        }
        
        @Test func deleteSystemModels() async throws {
            // given
            await projectModelRef.createFirstSystem()
            
            let systemModel = try #require(await projectModelRef.systems.values.first)
            
            try await #require(systemModel.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(systemModel.isExist == false)
        }
        @Test func deleteObjectModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await #require(objectModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(objectModelRef.id.isExist == false)
        }
        @Test func deleteStateModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            
            try await #require(stateModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(stateModelRef.id.isExist == false)
        }
        @Test func deleteGetterModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            let getterModelRef = try await createGetterModel(stateModelRef)
            
            try await #require(getterModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(getterModelRef.id.isExist == false)
        }
        @Test func deleteSetterModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let stateModelRef = try await createStateModel(objectModelRef)
            let setterModelRef = try await createSetterModel(stateModelRef)
            
            try await #require(setterModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(setterModelRef.id.isExist == false)
        }
        @Test func deleteActionModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let actionModelRef = try await createActionModel(objectModelRef)
            
            try await #require(actionModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(actionModelRef.id.isExist == false)
        }
        @Test func deleteFlowModels() async throws {
            // given
            let systemModelRef = try await createSystemModel(projectModelRef)
            let objectModelRef = try await createRootObjectModel(systemModelRef)
            let actionModelRef = try await createActionModel(objectModelRef)
            let flowModelRef = try await createFlowModel(actionModelRef)
            
            try await #require(flowModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(flowModelRef.id.isExist == false)
        }
        
        @Test func deleteValueModels() async throws {
            // given
            try await #require(projectModelRef.values.isEmpty)
            
            await projectModelRef.createValue()
            await projectModelRef.createValue()
            
            try await #require(projectModelRef.values.isEmpty == false)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            for valueModel in await projectModelRef.values.values {
                await #expect(valueModel.isExist == false)
            }
        }
        
        @Test func removeProjectModel_BudLocal() async throws {
            // given
            let project = projectModelRef.target
            
            let budLocalRef = try #require(await projectModelRef.owner.ref)
            try await #require(budLocalRef.projects[project] != nil)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(budLocalRef.projects[project] == nil)
        }
        @Test func deleteProjectModel() async throws {
            // given
            try await #require(projectModelRef.id.isExist == true)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            await #expect(projectModelRef.id.isExist == false)
        }
    }
}


// MARK: Helphers
private func getProjectModel(_ budLocalRef: BudLocal) async throws -> ProjectModel {
    // createProjectModel
    try await #require(budLocalRef.projects.isEmpty)
    
    await budLocalRef.createProject()
    
    let projectModel = try #require(await budLocalRef.projects.values.first)
    let projectModelRef = try #require(await projectModel.ref)
    
    return projectModelRef
}

private func createSystemModel(_ projectModelRef: ProjectModel) async throws -> SystemModel {
    try await #require(projectModelRef.systems.count == 0)
    
    await projectModelRef.createFirstSystem()
    
    try await #require(projectModelRef.systems.count == 1)
    
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

