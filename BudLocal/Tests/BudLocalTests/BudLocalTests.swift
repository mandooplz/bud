//
//  BudLocalTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
import ValueSuite
@testable import BudLocal


// MARK: Tests
@Suite("BudLocal", .timeLimit(.minutes(1)))
struct BudLocalTests {
    struct CreateProject {
        let budLocalRef: BudLocal
        init() async throws {
            self.budLocalRef = await BudLocal()
        }
        
        @Test func whenBudLocalIsDeletedBeforeMutate() async throws {
            // given
            try await #require(budLocalRef.id.isExist == true)
            
            await budLocalRef.setMutateHook {
                await budLocalRef.delete()
            }
            
            // when
            await budLocalRef.createProject()
            
            // then
            let issue = try #require(await budLocalRef.issue as? KnownIssue)
            #expect(issue.reason == "budLocalIsDeleted")
        }
        
        @Test func appendProjectModel() async throws {
            // given
            try await #require(budLocalRef.projects.isEmpty)
            
            // when
            await budLocalRef.createProject()
            
            // then
            await #expect(budLocalRef.projects.count == 1)
        }
        @Test func createProjetModel() async throws {
            // given
            try await #require(budLocalRef.projects.isEmpty)
            
            // when
            await budLocalRef.createProject()
            
            // then
            try await #require(budLocalRef.projects.count == 1)
            
            let projectModel = try #require(await budLocalRef.projects.values.first)
            await #expect(projectModel.isExist == true)
        }
    }
}
