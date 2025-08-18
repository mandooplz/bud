//
//  ActionModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("ActionModel", .timeLimit(.minutes(1)))
struct ActionModelTests {
    struct AddFailureEffect {
        let budLocalRef: BudLocal
        let actionModelRef: ActionModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.actionModelRef = try await getActionModel(budLocalRef)
            self.objectModelRef = try #require(await actionModelRef.owner.ref)
        }
        
        @Test func whenActionModelIsDeleted() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            await actionModelRef.setCaptureHook {
                await actionModelRef.delete()
            }
            
            // when
            await actionModelRef.addFailureEffect()
            
            // then
            let issue = try #require(await actionModelRef.issue as? KnownIssue)
            #expect(issue.reason == "actionModelIsDeleted")
        }
    }
    
    struct AddSuccessEffect {
        let budLocalRef: BudLocal
        let actionModelRef: ActionModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.actionModelRef = try await getActionModel(budLocalRef)
            self.objectModelRef = try #require(await actionModelRef.owner.ref)
        }
        
        @Test func whenActionModelIsDeleted() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            await actionModelRef.setCaptureHook {
                await actionModelRef.delete()
            }
            
            // when
            await actionModelRef.addSuccessEffect()
            
            // then
            let issue = try #require(await actionModelRef.issue as? KnownIssue)
            #expect(issue.reason == "actionModelIsDeleted")
        }
    }
    
    struct CreateFlow {
        let budLocalRef: BudLocal
        let actionModelRef: ActionModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.actionModelRef = try await getActionModel(budLocalRef)
            self.objectModelRef = try #require(await actionModelRef.owner.ref)
        }
        
        @Test func whenActionModelIsDeleted() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            await actionModelRef.setCaptureHook {
                await actionModelRef.delete()
            }
            
            // when
            await actionModelRef.createFlow()
            
            // then
            let issue = try #require(await actionModelRef.issue as? KnownIssue)
            #expect(issue.reason == "actionModelIsDeleted")
        }
        
        @Test func appendFlowModel_ObjectModel() async throws {
            // given
            try await #require(objectModelRef.flows.count == 0)
            
            // when
            await actionModelRef.createFlow()
            
            // then
            await #expect(objectModelRef.flows.count == 1)
        }
        @Test func createFlowModel() async throws {
            // given
            try await #require(objectModelRef.flows.count == 0)
            
            // when
            await actionModelRef.createFlow()
            
            // then
            try await #require(objectModelRef.flows.count == 1)
            
            let flowModel = try #require(await objectModelRef.flows.values.first)
            await #expect(flowModel.isExist == true)
        }
        @Test func setAction_FlowModel() async throws {
            // given
            let action = actionModelRef.target
            
            try await #require(objectModelRef.flows.count == 0)
            
            // when
            await actionModelRef.createFlow()
            
            // then
            try await #require(objectModelRef.flows.count == 1)
            
            let flowModelRef = try #require(await objectModelRef.flows.first?.value.ref)
            #expect(flowModelRef.action == action)
        }
    }
    
    struct LinkExternalFlow {
        let budLocalRef: BudLocal
        let actionModelRef: ActionModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.actionModelRef = try await getActionModel(budLocalRef)
            self.objectModelRef = try #require(await actionModelRef.owner.ref)
        }
        
        @Test func whenActionModelIsDeleted() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            await actionModelRef.setCaptureHook {
                await actionModelRef.delete()
            }
            
            // when
            await actionModelRef.linkExternalFlow()
            
            // then
            let issue = try #require(await actionModelRef.issue as? KnownIssue)
            #expect(issue.reason == "actionModelIsDeleted")
        }
    }
    
    struct RemoveAction {
        let budLocalRef: BudLocal
        let actionModelRef: ActionModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.actionModelRef = try await getActionModel(budLocalRef)
            self.objectModelRef = try #require(await actionModelRef.owner.ref)
        }
        
        @Test func whenActionModelIsDeleted() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            await actionModelRef.setCaptureHook {
                await actionModelRef.delete()
            }
            
            // when
            await actionModelRef.removeAction()
            
            // then
            let issue = try #require(await actionModelRef.issue as? KnownIssue)
            #expect(issue.reason == "actionModelIsDeleted")
        }
        
        @Test func removeActionModel_ObjectModel() async throws {
            // given
            let action = actionModelRef.target
            
            try await #require(objectModelRef.actions[action] != nil)
            
            // when
            await actionModelRef.removeAction()
            
            // then
            await #expect(objectModelRef.actions[action] == nil)
        }
        @Test func deleteActionModel() async throws {
            // given
            try await #require(actionModelRef.id.isExist == true)
            
            // when
            await actionModelRef.removeAction()
            
            // then
            await #expect(actionModelRef.id.isExist == false)
        }
        
        @Test func removeRelatedFlowModel_ObjectModel() async throws {
            // given
            try await #require(objectModelRef.flows.count == 0)
            
            await actionModelRef.createFlow()
            await actionModelRef.createFlow()
            
            try await #require(objectModelRef.flows.count == 2)
            
            for flowModel in await objectModelRef.flows.values {
                await #expect(flowModel.ref?.action == actionModelRef.target)
            }
            
            // when
            await actionModelRef.removeAction()
            
            // then
            await #expect(objectModelRef.flows.count == 0)
        }
        @Test func deleteRelatedFlowModel() async throws {
            // given
            try await #require(objectModelRef.flows.count == 0)
            
            await actionModelRef.createFlow()
            await actionModelRef.createFlow()
            
            let flowModels = await objectModelRef.flows.values
            try #require(flowModels.count == 2)
            
            // when
            await actionModelRef.removeAction()
            
            // then
            for flowModel in flowModels {
                await #expect(flowModel.isExist == false)
            }
        }
    }
}


// MARK: Helphers
private func getActionModel(_ budLocalRef: BudLocal) async throws -> ActionModel {
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
    
    // create ActionModel
    try await #require(rootobjectModelRef.actions.count == 0)
    
    await rootobjectModelRef.createNewAction()
    
    try await #require(rootobjectModelRef.actions.count == 1)
    
    let actionModel = try #require(await rootobjectModelRef.actions.values.first)
    let actionModelRef = try #require(await actionModel.ref)
    return actionModelRef
}

