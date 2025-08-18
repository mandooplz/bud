//
//  FlowModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/18/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("FlowModel", .timeLimit(.minutes(1)))
struct FlowModelTests {
    struct RemoveFlow {
        let budLocalRef: BudLocal
        let flowModelRef: FlowModel
        let objectModelRef: ObjectModel
        init() async throws {
            self.budLocalRef = await BudLocal()
            self.flowModelRef = try await getFlowModel(budLocalRef)
            self.objectModelRef = try #require(await flowModelRef.owner.ref)
        }
        
        @Test func whenFlowModelIsDeleted() async throws {
            // given
            try await #require(flowModelRef.id.isExist == true)
            
            await flowModelRef.setCaptureHook {
                await flowModelRef.delete()
            }
            
            // when
            await flowModelRef.removeFlow()
            
            // then
            let issue = try #require(await flowModelRef.issue as? KnownIssue)
            #expect(issue.reason == "flowModelIsDeleted")
        }
        
        @Test func removeFlowModel_ObjectModel() async throws {
            // given
            let flow = flowModelRef.target
            
            try await #require(objectModelRef.flows[flow] != nil)
            
            // when
            await flowModelRef.removeFlow()
            
            // then
            await #expect(objectModelRef.flows[flow] == nil)
        }
        @Test func deleteFlowModel() async throws {
            // given
            try await #require(flowModelRef.id.isExist == true)
            
            // when
            await flowModelRef.removeFlow()
            
            // then
            await #expect(flowModelRef.id.isExist == false)
        }
    }
}


// MARK: Helphers
private func getFlowModel(_ budLocalRef: BudLocal) async throws -> FlowModel {
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
    
    // create FlowModel
    try await #require(rootobjectModelRef.flows.count == 0)
    
    await actionModelRef.createFlow()
    
    try await #require(rootobjectModelRef.flows.count == 1)
    
    let flowModel =  try #require(await rootobjectModelRef.flows.values.first)
    let flowModelRef = try #require(await flowModel.ref)
    return flowModelRef
}
