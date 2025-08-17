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
            try await #require(projectModelRef.systems.isEmpty)
            
            await projectModelRef.createFirstSystem()
            
            try await #require(projectModelRef.systems.isEmpty == false)
            
            // when
            await projectModelRef.removeProject()
            
            // then
            for systemModel in await projectModelRef.systems.values {
                await #expect(systemModel.isExist == false)
            }
        }
        @Test func deleteObjectModels() async throws {
            // given
            
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
 

