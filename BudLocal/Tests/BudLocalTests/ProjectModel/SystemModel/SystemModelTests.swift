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
        
        @Test func deleteSystemModel() async throws {
            // given
            try await #require(systemModelRef.id.isExist == true)
            
            // when
            await systemModelRef.removeSystem()
            
            // then
            await #expect(systemModelRef.id.isExist == false)
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
