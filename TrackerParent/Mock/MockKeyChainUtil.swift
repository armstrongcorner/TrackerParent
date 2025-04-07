//
//  MockKeyChainUtil.swift
//  TrackerParent
//
//  Created by Armstrong Liu on 07/04/2025.
//

import Foundation

final class MockKeyChainUtil: KeyChainUtilProtocol {
    var authModel: AuthModel?
    
    func save(service: String, account: String, data: Data) -> OSStatus {
        return errSecSuccess
    }
    
    @discardableResult
    func saveObject<T: Encodable>(service: String, account: String, object: T) throws -> OSStatus {
        authModel = object as? AuthModel
        return errSecSuccess
    }
    
    func load(service: String, account: String) -> Data? {
        return nil
    }
    
    func loadObject<T: Decodable>(service: String, account: String, type: T.Type) throws -> T? {
        return authModel as? T
    }
    
    func delete(service: String, account: String) -> OSStatus {
        return errSecSuccess
    }
}
