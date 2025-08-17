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
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.valueModelRef = try await getValueModel(budLocalRef)
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

