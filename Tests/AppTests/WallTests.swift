//
//  File.swift
//  
//
//  Created by Danny Sung on 02/01/2020.
//

import XCTest
@testable import App
import SampleFeedUtilities

class WallTests: XCTestCase {
    let serverUrl = URL(string: "http://localhost:8080")!
    var httpClient: SampleHTTPClient!
    
    override func setUp() {
        self.httpClient = SampleHTTPClient(baseUrl: self.serverUrl)
        self.httpClient.defaultHeaders = [
            "Content-Type" : "application/json"
        ]
        
        try? self.httpClient.login(username: "johndoe", password: "secret")
    }
    override func tearDown() {
        try? self.httpClient.logout()
    }
    
//    func testThatUserCanCreateWall() throws {
//        let username = "test.create_wall"
//        let password = "test_secret"
//        let displayName = "testThatUserCanCreateWall()"
//        try? httpClient.createUser(username: username, password: password, displayName: displayName)
//        try httpClient.login(username: username, password: password)
//        
//    }
//    
    func testThatMainPageDoesNotExist() throws {
        let expectedStatus = 404
        let (resp,_) = try self.httpClient.get("/")
        
        // 404 means server is up, but page does not exist.
        XCTAssertTrue(resp.statusCode == expectedStatus, "Main page should return not found")
    }
    
    static let allTests = [
        ("testThatMainPageDoesNotExist", testThatMainPageDoesNotExist),
    ]
}
