//
//  SystemID.swift
//  BudClient
//
//  Created by 김민우 on 7/4/25.
//
import Foundation


// MARK: SystemID
public struct SystemID: IDRepresentable {
    public let value: UUID
    
    public init(value: UUID = UUID()) {
        self.value = value
    }
}


// MARK: SystemGroupID
public struct SysGroupID: IDRepresentable {
    public let value: UUID
    
    public init(value: UUID = UUID()) {
        self.value = value
    }
}


// MARK: SystemMode
@frozen
public enum SystemMode: Sendable, Hashable, Codable {
    case test
    case real
}





// MARK: SystemRole
@frozen
public enum SystemRole: Sendable, Hashable, CodingKey {
    case local
    case shared
}
