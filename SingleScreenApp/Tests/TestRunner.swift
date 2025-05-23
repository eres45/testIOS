import XCTest

class TestRunner {
    func runTests() {
        let testSuite = UserServiceTests.defaultTestSuite
        testSuite.run()
        
        print("Tests completed with \(testSuite.testRun?.failureCount ?? 0) failures")
    }
}

#if DEBUG
// This would be used when manually running tests
let testRunner = TestRunner()
testRunner.runTests()
#endif 