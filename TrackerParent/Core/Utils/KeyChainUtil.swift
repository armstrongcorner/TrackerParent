//
//  KeyChainUtil.swift
//  AbcTest
//
//  Created by Armstrong Liu on 14/03/2025.
//

import Foundation
import Security

protocol KeyChainUtilProtocol {
    func save(service: String, account: String, data: Data) -> OSStatus
    func saveObject<T: Encodable>(service: String, account: String, object: T) throws -> OSStatus
    func load(service: String, account: String) -> Data?
    func loadObject<T: Decodable>(service: String, account: String, type: T.Type) throws -> T?
    func delete(service: String, account: String) -> OSStatus
}

struct KeyChainUtil: KeyChainUtilProtocol {
    static let shared = KeyChainUtil()
    
    private init() {}
    
    /// Save original binary data to keychain
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    ///   - account: Used to distinguish different items in keychain. eg: username for saving different auth token
    ///   - data: Original binary data which needs to be saved to the keychain
    /// - Returns: OSStatus code，errSecSuccess means operation success
    @discardableResult
    func save(service: String, account: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // Remove the outdated data if existed
        SecItemDelete(query as CFDictionary)
        
        // Add the new data
        let result = SecItemAdd(query as CFDictionary, nil)
        return result
    }
    
    /// Save object (confirm Encodable) to keychain
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    ///   - account: Used to distinguish different items in keychain. eg: username for saving different auth token
    ///   - object: Object (Encodable) which needs to be saved to the keychain
    /// - Returns: OSStatus code，errSecSuccess means operation success
    @discardableResult
    func saveObject<T: Encodable>(service: String, account: String, object: T) throws -> OSStatus {
        do {
            let data = try JSONEncoder().encode(object)
            let result = save(service: service, account: account, data: data)
            return result
        } catch {
            throw ApiError.encodingFailed("Failed to encode response data: \(error)")
        }
    }
    
    /// Delete keychain data
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    ///   - account: Used to distinguish different items in keychain. eg: username for saving different auth token
    /// - Returns: OSStatus code，errSecSuccess means operation success
    @discardableResult
    func delete(service: String, account: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        let result = SecItemDelete(query as CFDictionary)
        return result
    }
    
    /// Load the binary data from keychain
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    ///   - account: Used to distinguish different items in keychain. eg: username for saving different auth token
    /// - Returns: Return the exactly matched one binary data, otherwise return nil
    func load(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        
        return nil
    }
    
    /// Load the specified type object from keychain
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    ///   - account: Used to distinguish different items in keychain. eg: username for saving different auth token
    ///   - type: Type of loaded object
    /// - Returns: Return the exactly matched one object (Decodable), otherwise return nil
    func loadObject<T: Decodable>(service: String, account: String, type: T.Type) throws -> T? {
        guard let data = load(service: service, account: account) else { return nil }
        
        do {
            let object = try JSONDecoder().decode(type, from: data)
            return object
        } catch {
            throw ApiError.decodingFailed("Failed to decode response data: \(error)")
        }
    }
    
    /// Load all items from specified service name (like: com.example.appname)
    /// - Parameters:
    ///   - service: Consider service name is app's bundle id
    /// - Returns: Return the items matched with the service name, otherwise return nil
    func loadAllItems(service: String) throws -> [[String: Any]]? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitAll
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? [[String: Any]]
        } else {
            print("keychain query status: \(status)")
            throw CommError.unknown
        }
    }
}
