//
//  SetterModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("SetterModel", .timeLimit(.minutes(1)))
struct SetterModelTests {
    struct RemoveSetter {
        let budLocalRef: BudLocal
        let setterModelRef: SetterModel
        let stateModelRef: StateModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.setterModelRef = try await getSetterModel(budLocalRef)
            self.stateModelRef = try #require(await setterModelRef.owner.ref)
        }
        
        @Test func whenSetterModelIsDeleted() async throws {
            // given
            try await #require(stateModelRef.id.isExist == true)
            
            await setterModelRef.setCaptureHook {
                await setterModelRef.delete()
            }
            
            // when
            await setterModelRef.removeSetter()
            
            // then
            let issue = try #require(await setterModelRef.issue as? KnownIssue)
            #expect(issue.reason == "setterModelIsDeleted")
        }
        
        @Test func removeSetterModel_StateModel() async throws {
            // given
            let setter = setterModelRef.target
            
            try await #require(stateModelRef.setters[setter] != nil)
            
            // when
            await setterModelRef.removeSetter()
            
            // then
            await #expect(stateModelRef.setters[setter] == nil)
        }
        @Test func deleteSetterModel() async throws {
            // given
            try await #require(setterModelRef.id.isExist == true)
            
            // when
            await setterModelRef.removeSetter()
            
            // then
            await #expect(setterModelRef.id.isExist == false)
        }
        
        @Test func removeSetter_FlowModel() async throws {
            // given
            let objectModelRef = try #require(await stateModelRef.owner.ref)
            let actionModelRef = try await createActionModel(objectModelRef)
            let flowModelRef = try await createFlowModel(actionModelRef)
            
            let oldValue: [SetterID] = [setterModelRef.target]
            let newValue: [SetterID] = []
            
            await MainActor.run {
                flowModelRef.setters = oldValue
            }
            
            // when
            await setterModelRef.removeSetter()
            
            // then
            await #expect(flowModelRef.setters == newValue)
        }
    }
}


// MARK: Helphers
private func getSetterModel(_ budLocalRef: BudLocal) async throws -> SetterModel {
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
    
    // create StateModel
    try await #require(rootobjectModelRef.states.count == 0)
    
    await rootobjectModelRef.createNewState()
    
    try await #require(rootobjectModelRef.states.count == 1)
    
    let stateModel = try #require(await rootobjectModelRef.states.values.first)
    let stateModelRef = try #require(await stateModel.ref)
    
    // create SetterModel
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
