//
//  ProfileTests.swift
//  BudClient
//
//  Created by 김민우 on 6/26/25.
//
import Foundation
import Testing
@testable import BudClient
import Values


// MARK: Tests
@Suite("Profile", .timeLimit(.minutes(1)))
struct ProfileTests {
    struct SignOut {
        let budClientRef: BudClient
        let profileRef: Profile
        init() async throws {
            self.budClientRef = await BudClient()
            self.profileRef = try await getProfileBoard(budClientRef)
        }
        
        @Test func whenProfileBoardIsDeletedBeforeCapture() async throws {
            // given
            
            try await #require(budClientRef.profile?.isExist == true)
            
            await budClientRef.saveUserInCache()
            let budCacheRef = try #require(await profileRef.config.budCache.ref)
            try await #require(budCacheRef.getUser() != nil)
            
            await profileRef.setCaptureHook {
                await profileRef.delete()
            }
            
            // when
            await profileRef.signOut()

            // then
            let issue = try #require(await profileRef.issue as? KnownIssue)
            #expect(issue.reason == "profileBoardIsDeleted")
            
            try await #require(budClientRef.profile?.isExist == false)
            await #expect(budCacheRef.getUser() != nil)
        }
        @Test func whenProfileBoardIsDeletedBeforeMutate() async throws {
            // given
            try await #require(budClientRef.profile?.isExist == true)
            
            await budClientRef.saveUserInCache()
            let budCacheRef = try #require(await profileRef.config.budCache.ref)
            try await #require(budCacheRef.getUser() != nil)
            
            await profileRef.setMutateHook {
                await profileRef.delete()
            }
            
            // when
            await profileRef.signOut()
            
            // then
            let issue = try #require(await profileRef.issue as? KnownIssue)
            #expect(issue.reason == "profileBoardIsDeleted")
            
            try await #require(budClientRef.profile?.isExist == false)
            await #expect(budClientRef.isUserSignedIn == true)
        }
        
        // TODO: 하위 객체들을 계속해서 추가해야 함
        @Test func setIsUserSignedInAtBudClient() async throws {
            // given
            try await #require(budClientRef.isUserSignedIn == true)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(budClientRef.isUserSignedIn == false)
        }
        
        @Test func setSignInFormInBudClient() async throws {
            // given
            try await #require(budClientRef.signInForm == nil)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(budClientRef.signInForm != nil)
        }
        @Test func createSignInForm() async throws {
            // given
            try await #require(budClientRef.signInForm == nil)
            
            // when
            await profileRef.signOut()
            
            // then
            let signInForm = try #require(await budClientRef.signInForm)
            await #expect(signInForm.isExist == true)
        }
        
        @Test func deleteProjectBoard() async throws {
            // given
            let projectBoard = try #require(await budClientRef.projectBoard)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(projectBoard.isExist == false)
        }
        @Test func deleteProjectModels() async throws {
            // given
            let projectBoardRef = try #require(await budClientRef.projectBoard?.ref)
            
            await projectBoardRef.startUpdating()
            
            let runTime = Int.random(in: 1...10)
            for _ in 1...runTime {
                await withCheckedContinuation { continuation in
                    Task {
                        await projectBoardRef.setCallback {
                            continuation.resume()
                        }
                        
                        await projectBoardRef.createProject()
                    }
                }
            }
            
            
            try await #require(projectBoardRef.projects.count == runTime)
        
            // when
            await profileRef.signOut()
            
            // then
            for projectModel in await projectBoardRef.projects.values {
                await #expect(projectModel.isExist == false)
            }
        }
        
        @Test func deleteSystemModels() async throws {
            // given
            let projectModelRef = try await createProjectModel(budClientRef)
            
            await projectModelRef.startUpdating()
            await withCheckedContinuation { continuation in
                Task {
                    await projectModelRef.setCallback {
                        continuation.resume()
                    }
                    
                    await projectModelRef.createFirstSystem()
                }
            }
            
            
            try await #require(projectModelRef.systems.count == 1)
            
            // when
            await profileRef.signOut()
            
            // then
            for systemModel in await projectModelRef.systems.values {
                await #expect(systemModel.isExist == false)
            }
        }
        @Test func deleteRootObjectModel() async throws {
            // given
            let projectModelRef = try await createProjectModel(budClientRef)
            let systemModelRef = try await createSystemModel(projectModelRef)
            let rootObjectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await #require(rootObjectModelRef.id.isExist == true)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(rootObjectModelRef.id.isExist == false)
        }
        @Test func deleteObjectModels() async throws {
            // given
            let projectModelRef = try await createProjectModel(budClientRef)
            let systemModelRef = try await createSystemModel(projectModelRef)
            let rootObjectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await createChildObject(rootObjectModelRef)
            try await createChildObject(rootObjectModelRef)
            
            try await #require(systemModelRef.objects.count == 3)
            
            // when
            await profileRef.signOut()
            
            // then
            for objectModel in await systemModelRef.objects.values {
                await #expect(objectModel.isExist == false)
            }
        }
        @Test func deleteStateModels() async throws {
            // given
            let projectModelRef = try await createProjectModel(budClientRef)
            let systemModelRef = try await createSystemModel(projectModelRef)
            let rootObjectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await #require(systemModelRef.objects.count == 1)
            
            // given
            try await #require(rootObjectModelRef.states.count == 0)
            
            try await createStateModel(rootObjectModelRef)
            try await createStateModel(rootObjectModelRef)
            
            try await #require(rootObjectModelRef.states.count == 2)
            
            // when
            await profileRef.signOut()
            
            // then
            for stateModel in await rootObjectModelRef.states.values {
                await #expect(stateModel.isExist == false)
            }
        }
        @Test func deleteActionModels() async throws {
            // given
            let projectModelRef = try await createProjectModel(budClientRef)
            let systemModelRef = try await createSystemModel(projectModelRef)
            let rootObjectModelRef = try await createRootObjectModel(systemModelRef)
            
            try await #require(systemModelRef.objects.count == 1)
            
            // given
            try await #require(rootObjectModelRef.actions.count == 0)
            
            try await createActionModel(rootObjectModelRef)
            try await createActionModel(rootObjectModelRef)
            
            try await #require(rootObjectModelRef.actions.count == 2)
            
            // when
            await profileRef.signOut()
            
            // then
            for actionModel in await rootObjectModelRef.actions.values {
                await #expect(actionModel.isExist == false)
            }
        }
        
        @Test func deleteProfile() async throws {
            // given
            let profileBoard = try #require(await budClientRef.profile)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(budClientRef.profile == nil)
            await #expect(profileBoard.isExist == false)
        }
        @Test func deleteCommunity() async throws {
            // given
            let community = try #require(await budClientRef.community)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(community.isExist == false
            )
        }
        
        @Test func setNilUserIdInBudCache() async throws {
            // given
            await budClientRef.saveUserInCache()
            
            let budCacheRef = try #require(await profileRef.config.budCache.ref)
            try await #require(budCacheRef.getUser() != nil)
            
            // when
            await profileRef.signOut()
            
            // then
            await #expect(budCacheRef.getUser() == nil)
        }
    }
}


// MARK: Helphers
private func getProfileBoard(_ budClientRef: BudClient) async throws -> Profile {
    // BudClient.setUp()
    await budClientRef.setUp()
    let signInForm = try #require(await budClientRef.signInForm)
    let signInFormRef = try #require(await signInForm.ref)
    
    // SignInForm.setUpSignUpForm()
    await signInFormRef.setUpSignUpForm()
    let signUpFormRef = try #require(await signInFormRef.signUpForm?.ref)
    
    // SignUpForm.submit()
    let testEmail = Email.random().value
    let testPassword = Password.random().value
    await MainActor.run {
        signUpFormRef.email = testEmail
        signUpFormRef.password = testPassword
        signUpFormRef.passwordCheck = testPassword
    }
    
    await signUpFormRef.submit()
    
    // Profile
    let profileBoardRef = try #require(await budClientRef.profile?.ref)
    return profileBoardRef
}

private func createProjectModel(_ budClientRef: BudClient) async throws -> ProjectModel {
    // check
    let projectBoardRef = try #require(await budClientRef.projectBoard?.ref)
    
    // ProjectBoard.createNewProject
    await projectBoardRef.startUpdating()
    await withCheckedContinuation { continuation in
        Task {
            await projectBoardRef.setCallback {
                continuation.resume()
            }
            
            await projectBoardRef.createProject()
        }
    }
    
    // ProjectEditor
    await #expect(projectBoardRef.projects.count == 1)
    return try #require(await projectBoardRef.projects.values.first?.ref)
}

private func createSystemModel(_ projectModelRef: ProjectModel) async throws -> SystemModel {
    // SystemBoard.createFirstSystem
    await projectModelRef.startUpdating()
    await withCheckedContinuation { continuation in
        Task {
            await projectModelRef.setCallback {
                continuation.resume()
            }
            
            await projectModelRef.createFirstSystem()
        }
    }
    
    // SystemModel
    let systemModelRef = try #require(await projectModelRef.systems.values.first?.ref)
    return systemModelRef
}

private func createRootObjectModel(_ systemModelRef: SystemModel) async throws -> ObjectModel {
    await systemModelRef.startUpdating()
    try await #require(systemModelRef.isUpdating == true)
    
    await withCheckedContinuation { continuation in
        Task {
            await systemModelRef.setCallback {
                continuation.resume()
            }
            
            await systemModelRef.createRootObject()
        }
    }
    
    let rootObjectModel = try #require(await systemModelRef.root)
    return try #require(await rootObjectModel.ref)
}

private func createChildObject(_ rootObjectModelRef: ObjectModel) async throws {
    let systemModelRef = try #require(await rootObjectModelRef.config.parent.ref)
    try await #require(systemModelRef.isUpdating == true)
    
    let oldCount = await systemModelRef.objects.count
    
    await withCheckedContinuation { continuation in
        Task {
            await systemModelRef.setCallback {
                continuation.resume()
            }
            
            await rootObjectModelRef.createChildObject()
        }
    }
    
    let newCount = await systemModelRef.objects.count
    
    try #require(newCount == oldCount + 1)
    return
}

private func createStateModel(_ objectModelRef: ObjectModel) async throws {
    await objectModelRef.startUpdating()
    try await #require(objectModelRef.isUpdating == true)
    
    let oldCount = await objectModelRef.states.count
    
    await withCheckedContinuation { continuation in
        Task {
            await objectModelRef.setCallback {
                continuation.resume()
            }
            
            await objectModelRef.appendNewState()
        }
    }
    
    #expect(await objectModelRef.states.count == oldCount + 1)
}

private func createActionModel(_ objectModelRef: ObjectModel) async throws {
    await objectModelRef.startUpdating()
    try await #require(objectModelRef.isUpdating == true)
    
    let oldCount = await objectModelRef.actions.count
    
    await withCheckedContinuation { continuation in
        Task {
            await objectModelRef.setCallback {
                continuation.resume()
            }
            
            await objectModelRef.appendNewAction()
        }
    }
    
    #expect(await objectModelRef.actions.count == oldCount + 1)
}
