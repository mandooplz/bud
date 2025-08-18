//
//  GetterModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("GetterModel", .timeLimit(.minutes(1)))
struct GetterModelTests {
    struct RemoveGetter {
        let budLocalRef: BudLocal
        let getterModelRef: GetterModel
        let stateModelRef: StateModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.getterModelRef = try await getGetterModel(budLocalRef)
            self.stateModelRef = try #require(await getterModelRef.owner.ref)
        }
        
        @Test func whenGetterModelIsDeleted() async throws {
            // given
            try await #require(getterModelRef.id.isExist == true)
            
            await getterModelRef.setCaptureHook {
                await getterModelRef.delete()
            }
            
            // when
            await getterModelRef.removeGetter()
            
            // then
            let issue = try #require(await getterModelRef.issue as? KnownIssue)
            #expect(issue.reason == "getterModelIsDeleted")
        }
        
        @Test func removeGetterModel_StateModel() async throws {
            // given
            let getter = getterModelRef.target
            
            try await #require(stateModelRef.getters[getter] != nil)
            
            // when
            await getterModelRef.removeGetter()
            
            // then
            await #expect(stateModelRef.getters[getter] == nil)
        }
        @Test func deleteGetterModel() async throws {
            // given
            try await #require(getterModelRef.id.isExist == true)
            
            // when
            await getterModelRef.removeGetter()
            
            // then
            await #expect(getterModelRef.id.isExist == false)
        }
    }
}


// MARK: Helphers
private func getGetterModel(_ budLocalRef: BudLocal) async throws -> GetterModel {
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
    
    // create GetterModel
    try await #require(stateModelRef.getters.count == 0)
    
    await stateModelRef.createGetter()
    
    try await #require(stateModelRef.getters.count == 1)
    
    let getterModel = try #require(await stateModelRef.getters.values.first)
    let getterModelRef = try #require(await getterModel.ref)
    return getterModelRef
}
