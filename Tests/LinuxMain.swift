#if os(Linux)

import XCTest
@testable import AuthTests
@testable import BasicTests

XCTMain([
    // AuthTests
    testCase(AuthTests.allTests),
    testCase(BasicTests.allTests),
])

#endif
