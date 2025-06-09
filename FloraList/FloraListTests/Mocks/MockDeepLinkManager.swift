//
//  MockDeepLinkManager.swift
//  FloraList
//
//  Created by User on 6/9/25.
//

import Foundation
@testable import FloraList

class MockDeepLinkManager: DeepLinkManager {
    var lastHandledURL: URL?
    var handleCallCount = 0
    var shouldThrowError = false

    override func handle(_ url: URL) async throws {
        lastHandledURL = url
        handleCallCount += 1

        if shouldThrowError {
            throw DeepLinkError.invalidURL
        }
    }
} 
