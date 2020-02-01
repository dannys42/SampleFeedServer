import XCTest
@testable import App
import SampleUtilities

class AppTests: XCTestCase {
    let serverUrl = URL(string: "http://localhost:8080")!
    var httpClient: SampleHTTPClient!
    
    override func setUp() {
        self.httpClient = SampleHTTPClient(baseUrl: self.serverUrl)
        self.httpClient.defaultHeaders = [
            "Content-Type" : "application/json"
        ]
    }
    override func tearDown() {
    }
    
    func testThatMainPageDoesNotExist() throws {
        let expectedStatus = 404
        let (resp,_) = try self.httpClient.get("/")
        
        // 404 means server is up, but page does not exist.
        XCTAssertTrue(resp.statusCode == expectedStatus, "Main page should return not found")

    }
    
    func testThatCannotCreateEmptyUser() throws {
        let expectedStatus = 400
        let (resp,_) = try self.httpClient.post("/users", [:])
        
        XCTAssertTrue(resp.statusCode == expectedStatus, "Should return error due to invalid parameters")
    }
    
    func testThatCanCreateUser() throws {
        let expectedStatus = 200
        let (resp,_) = try self.httpClient.post("/users",
                                                      [ "name" : "John Doe",
                                                        "email" : "john@somewhere.galaxy",
                                                        "password" : "secret",
                                                        "verifyPassword" : "secret"
        ])
        
        XCTAssertTrue(resp.statusCode == expectedStatus, "Should return error due to invalid parameters")
    }
    
    func testThatCannotCreateUserTwice() throws {
        let expectedStatus1 = 200
        let expectedStatus2 = 409
        let userInfo = [ "name" : "John Doe",
                         "email" : "john@somewhere.galaxy",
                         "password" : "secret",
                         "verifyPassword" : "secret"
        ]
        let (resp1,_) = try self.httpClient.post("/users", userInfo)

        XCTAssertTrue(resp1.statusCode == expectedStatus1, "Should return error due to invalid parameters  (status=\(resp1.statusCode)  expected=\(expectedStatus1))")

        let (resp2,_) = try self.httpClient.post("/users", userInfo)
        print("status: \(resp2.statusCode)")
        XCTAssertTrue(resp2.statusCode == expectedStatus2, "Should fail due to user already existing  (status=\(resp2.statusCode)  expected=\(expectedStatus2))")
    }
    
    func testThatUserCanLoginUnwrapped() throws {
        let email = "user1@somewhere.galaxy"
        let password = "mysecret"
        
        // first create the user.  Don't care if this part succeeds or fails as we test login after
        let userInfo = [ "name" : "User1",
                        "email" : email,
                        "password" : password,
                        "verifyPassword" : password
        ]
        let (_,_) = try self.httpClient.post("/users", userInfo)

        let tokenPlain = "\(email):\(password)"
        let tokenBase64 = tokenPlain.data(using: .utf8)?.base64EncodedString() ?? ""
        let headers = [
            "Authorization" : "Basic \(tokenBase64)"
        ]
        print("auth req header: \(headers)")
        
        let (resp2,body) = try self.httpClient.post("/login", headers: headers, [:])
        print("auth rsp body: \(body)")

        XCTAssertTrue(resp2.statusCode == 200, "Login should be successful")
        
        let authToken = body["string"] as? String
        XCTAssertNotNil(authToken, "Successful login should have auth token")
        XCTAssert(authToken != "", "Successful login should have a non-emtpy auth token")
    }
    func testThatUserCanLogin() throws {
        let email = "user1@somewhere.galaxy"
        let password = "mysecret"
        
        // first create the user.  Don't care if this part succeeds or fails as we test login after
        let userInfo = [ "name" : "User1",
                        "email" : email,
                        "password" : password,
                        "verifyPassword" : password
        ]
        let (_,_) = try self.httpClient.post("/users", userInfo)
        
        try self.httpClient.login(username: email, password: password)
    }

    static let allTests = [
        ("testThatMainPageDoesNotExist", testThatMainPageDoesNotExist),
        ("testThatCannotCreateEmptyUser", testThatCannotCreateEmptyUser),
        ("testThatCanCreateUser", testThatCanCreateUser),
        ("testThatCannotCreateUserTwice", testThatCannotCreateUserTwice),
        ("testThatUserCanLoginUnwrapped", testThatUserCanLoginUnwrapped),
        ("testThatUserCanLogin", testThatUserCanLogin),
    ]
}
