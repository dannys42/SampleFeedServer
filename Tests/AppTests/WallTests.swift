//
//  File.swift
//  
//
//  Created by Danny Sung on 02/01/2020.
//

import XCTest
@testable import App
import SampleUtilities

class WallTests: XCTestCase {
    let serverUrl = URL(string: "http://localhost:8080")!
    var httpClient: SampleHTTPClient!
    
    override func setUp() {
        self.httpClient = SampleHTTPClient(baseUrl: self.serverUrl)
        self.httpClient.defaultHeaders = [
            "Content-Type" : "application/json"
        ]
        
        self.httpClient.login(username: "johndoe", password: "secret")
    }
    override func tearDown() {
    }
    
    func testThatUserCanPost() throws {
        
    }
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
