//
//  ValueModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("ValueModel", .timeLimit(.minutes(1)))
struct ValueModelTests {
    struct RemoveValue {
        let budLocalRef: BudLocal
        let valueModelRef: ValueModel
        let projectModelRef: ProjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.valueModelRef = try await getValueModel(budLocalRef)
            self.projectModelRef = try #require(await valueModelRef.owner.ref)
        }
        
        @Test func whenValueModelIsDeleted() async throws {
            // given
            try await #require(valueModelRef.id.isExist == true)
            
            await valueModelRef.setCaptureHook {
                await valueModelRef.delete()
            }
            
            // when
            await valueModelRef.removeValue()
            
            // then
            let issue = try #require(await valueModelRef.issue as? KnownIssue)
            #expect(issue.reason == "valueModelIsDeleted")
        }
        
        @Test func deleteValueModel() async throws {
            // given
            try await #require(valueModelRef.id.isExist == true)
            
            // when
            await valueModelRef.removeValue()
            
            // then
            await #expect(valueModelRef.id.isExist == false)
        }
        @Test func removeValueModel_ProjectModel() async throws {
            // given
            let value = valueModelRef.target
            
            try await #require(projectModelRef.values[value] != nil)
            
            // when
            await valueModelRef.removeValue()
            
            // then
            await #expect(projectModelRef.values[value] == nil)
        }
        
        @Test func setTypeNilOfStateValue_StateModel() async throws {
            // given
            let stateModelRef = try await createStateModel(projectModelRef)
            
            let oldValue = StateValue(name: "TEST_STATE",
                                      type: valueModelRef.target)
            let newValue = StateValue(name: "TEST_STATE",
                                      type: nil)
            
            await MainActor.run {
                stateModelRef.stateValue = oldValue
            }
            
            try await #require(stateModelRef.stateValue?.type == valueModelRef.target)
            
            // when
            await valueModelRef.removeValue()
            
            // then
            try await #require(stateModelRef.stateValue != oldValue)
            
            await #expect(stateModelRef.stateValue == newValue)
        }
        
        @Test func setTypeNilOfParameterValue_GetterModel() async throws {
            // given
            let stateModelRef = try await createStateModel(projectModelRef)
            
            try await #require(stateModelRef.getters.count == 0)
            
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            
            try await #require(stateModelRef.getters.count == 3)
            
            // given
            let oldValue = ParameterValue(name: "TEST_NAME",
                                          type: valueModelRef.target)
            let newValue = oldValue.setType(nil)
            
            for getterModel in await stateModelRef.getters.values {
                await MainActor.run {
                    getterModel.ref?.parameters = [oldValue]
                }
            }
            
            // when
            await valueModelRef.removeValue()
            
            // then
            for getterModel in await stateModelRef.getters.values {
                await #expect(getterModel.ref?.parameters == [newValue])
            }
        }
        @Test func setTypeNilOfResult_GetterModel() async throws {
            // given
            let stateModelRef = try await createStateModel(projectModelRef)
            
            try await #require(stateModelRef.getters.count == 0)
            
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            await stateModelRef.createGetter()
            
            try await #require(stateModelRef.getters.count == 3)
            
            // given
            let oldValue = valueModelRef.target
            
            for getterModel in await stateModelRef.getters.values {
                await MainActor.run {
                    getterModel.ref?.result = oldValue
                }
            }
            
            // when
            await valueModelRef.removeValue()
            
            // then
            for getterModel in await stateModelRef.getters.values {
                await #expect(getterModel.ref?.result == nil)
            }
        }
        
        @Test func setTypeNilOfParameterValue_SetterModel() async throws {
            // given
            let stateModelRef = try await createStateModel(projectModelRef)
            
            try await #require(stateModelRef.setters.count == 0)
            
            await stateModelRef.createSetter()
            await stateModelRef.createSetter()
            await stateModelRef.createSetter()
            
            try await #require(stateModelRef.setters.count == 3)
            
            // given
            let oldValue = ParameterValue(name: "TEST_NAME",
                                          type: valueModelRef.target)
            let newValue = oldValue.setType(nil)
            
            for setterModel in await stateModelRef.setters.values {
                await MainActor.run {
                    setterModel.ref?.parameters = [oldValue]
                }
            }
            
            // when
            await valueModelRef.removeValue()
            
            // then
            for setterModel in await stateModelRef.setters.values {
                await #expect(setterModel.ref?.parameters == [newValue])
            }
        }
    }
}


// MARK: Helphers
private func getValueModel(_ budLocalRef: BudLocal) async throws -> ValueModel {
    // create ProjectModel
    try await #require(budLocalRef.projects.count == 0)
    
    await budLocalRef.createProject()
    
    try await #require(budLocalRef.projects.count == 1)
    
    
    // create ValueModel
    let projectModelRef = try #require(await budLocalRef.projects.values.first?.ref)
    
    await projectModelRef.createValue()
    
    
    // return
    let valueModel = try #require(await projectModelRef.values.values.first)
    let valueModelRef = try #require(await valueModel.ref)
    return valueModelRef
}

private func createStateModel(_ projectModelRef: ProjectModel) async throws -> StateModel {
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
