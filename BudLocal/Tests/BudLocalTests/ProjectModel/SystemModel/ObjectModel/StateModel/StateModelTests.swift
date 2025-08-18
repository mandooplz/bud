//
//  StateModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("StateModel", .timeLimit(.minutes(1)))
struct StateModelTests {
    struct CreateGetter {
        let budLocalRef: BudLocal
        let stateModelRef: StateModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.stateModelRef = try await getStateModel(budLocalRef)
        }
        
        @Test func whenStateModelIsDeleted() async throws {
            // given
            try await #require(stateModelRef.id.isExist == true)
            
            await stateModelRef.setCaptureHook {
                await stateModelRef.delete()
            }
            
            // when
            await stateModelRef.createGetter()
            
            // then
            let issue = try #require(await stateModelRef.issue as? KnownIssue)
            #expect(issue.reason == "stateModelIsDeleted")
        }
        
        @Test func appendGetterModel() async throws {
            // given
            try await #require(stateModelRef.getters.count == 0)
            
            // when
            await stateModelRef.createGetter()
            
            // then
            await #expect(stateModelRef.getters.count == 1)
        }
        @Test func createGetterModel() async throws {
            // given
            try await #require(stateModelRef.getters.count == 0)
            
            // when
            await stateModelRef.createGetter()
            
            // then
            try await #require(stateModelRef.getters.count == 1)
            
            let getterModel = try #require(await stateModelRef.getters.values.first)
            await #expect(getterModel.isExist == true)
        }
    }
    struct CreateSetter {
        let budLocalRef: BudLocal
        let stateModelRef: StateModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.stateModelRef = try await getStateModel(budLocalRef)
        }
        
        @Test func whenStateModelIsDeleted() async throws {
            // given
            try await #require(stateModelRef.id.isExist == true)
            
            await stateModelRef.setCaptureHook {
                await stateModelRef.delete()
            }
            
            // when
            await stateModelRef.createSetter()
            
            // then
            let issue = try #require(await stateModelRef.issue as? KnownIssue)
            #expect(issue.reason == "stateModelIsDeleted")
        }
        
        @Test func appendSetterModel() async throws {
            // given
            try await #require(stateModelRef.setters.count == 0)
            
            // when
            await stateModelRef.createSetter()
            
            // then
            await #expect(stateModelRef.setters.count == 1)
        }
        @Test func createSetterModel() async throws {
            // given
            try await #require(stateModelRef.setters.count == 0)
            
            // when
            await stateModelRef.createSetter()
            
            // then
            try await #require(stateModelRef.setters.count == 1)
            
            let setterModel = try #require(await stateModelRef.setters.values.first)
            await #expect(setterModel.isExist == true)
        }
    }
    
    struct RemoveState {
        let budLocalRef: BudLocal
        let stateModelRef: StateModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.stateModelRef = try await getStateModel(budLocalRef)
            self.objectModelRef = try #require(await stateModelRef.owner.ref)
        }
        
        @Test func whenStateModelIsDeleted() async throws {
            // given
            try await #require(stateModelRef.id.isExist == true)
            
            await stateModelRef.setCaptureHook {
                await stateModelRef.delete()
            }
            
            // when
            await stateModelRef.removeState()
            
            // then
            let issue = try #require(await stateModelRef.issue as? KnownIssue)
            #expect(issue.reason == "stateModelIsDeleted")
        }
        
        @Test func deleteGetterModels() async throws {
            // given
            try await #require(stateModelRef.getters.count == 0)
            
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            
            try await #require(stateModelRef.getters.count == 2)
            
            let getterModels = await stateModelRef.getters.values
            
            // when
            await stateModelRef.removeState()
            
            // then
            for getterModel in getterModels {
                await #expect(getterModel.isExist == false)
            }
        }
        @Test func deleteSetterModels() async throws {
            // given
            try await #require(stateModelRef.setters.count == 0)
            
            await stateModelRef.createSetter()
            await stateModelRef.createSetter()
            
            try await #require(stateModelRef.setters.count == 2)
            
            let setterModels = await stateModelRef.setters.values
            
            // when
            await stateModelRef.removeState()
            
            // then
            for setterModel in setterModels {
                await #expect(setterModel.isExist == false)
            }
        }
        
        @Test func removeStateModel_ObjectModel() async throws {
            // given
            let state = stateModelRef.target
            
            try await #require(objectModelRef.states[state] != nil)
            
            // when
            await stateModelRef.removeState()
            
            // then
            await #expect(objectModelRef.states[state] == nil)
        }
        @Test func deleteStateModel() async throws {
            // given
            try await #require(stateModelRef.id.isExist == true)
            
            // when
            await stateModelRef.removeState()
            
            // then
            await #expect(stateModelRef.id.isExist == false)
        }
    }
}


// MARK: Helphers
private func getStateModel(_ budLocalRef: BudLocal) async throws -> StateModel {
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
    return stateModelRef
}

