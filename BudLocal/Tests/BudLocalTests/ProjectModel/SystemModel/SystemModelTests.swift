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
            await systemModelRef.addSystemRight()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
    }
    
    struct AddSystemLeft {
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
            await systemModelRef.addSystemLeft()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
    }
    
    struct AddSystemTop {
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
            await systemModelRef.addSystemTop()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
        }
    }
    
    struct AddSystemBottom {
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
            await systemModelRef.addSystemBottom()
            
            // then
            let issue = try #require(await systemModelRef.issue as? KnownIssue)
            #expect(issue.reason == "systemModelIsDeleted")
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

