//
//  ValueModelTests.swift
//  BudLocal
//
//  Created by 김민우 on 8/17/25.
//
import Foundation
import Testing
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
    }
}


// MARK: Helphers
private func getValueModel(_ budLocalRef: BudLocal) async throws -> ValueModel {
    // create ProjectModel
    
    
    // create ValueModel
    
    fatalError()
}

