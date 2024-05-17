//
//  GTTestTests.swift
//  GTTestTests
//
//  Created by yutong on 2024/2/27.
//

import XCTest
@testable import GTTest

final class GTTestTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


class FriendsViewModelTests: XCTestCase {

    var viewModel: FriendsViewModel!

    override func setUp() {
        super.setUp()
        viewModel = FriendsViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testFetchPersonData() {
        let expectation = XCTestExpectation(description: "Fetch person data")

        viewModel.fetchPersonData(from: "https://dimanyen.github.io/man.json") { success in
            XCTAssertTrue(success, "Failed to fetch person data")
            XCTAssertNotNil(self.viewModel.person, "Person data is nil")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testFetchFriendsData1() {
        let expectation = XCTestExpectation(description: "Fetch friends data 1")

        viewModel.fetchFriendsData(from: "https://dimanyen.github.io/friend1.json") { success in
            XCTAssertTrue(success, "Failed to fetch friends data 1")
            XCTAssertFalse(self.viewModel.friends.isEmpty, "Friends data 1 is empty")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testFetchFriendsData2() {
        let expectation = XCTestExpectation(description: "Fetch friends data 2")

        viewModel.fetchFriendsData(from: "https://dimanyen.github.io/friend2.json") { success in
            XCTAssertTrue(success, "Failed to fetch friends data 2")
            XCTAssertFalse(self.viewModel.friends.isEmpty, "Friends data 2 is empty")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testFetchFriendsData3() {
        let expectation = XCTestExpectation(description: "Fetch friends data 3")

        viewModel.fetchFriendsData(from: "https://dimanyen.github.io/friend3.json") { success in
            XCTAssertTrue(success, "Failed to fetch friends data 3")
            XCTAssertFalse(self.viewModel.friends.isEmpty, "Friends data 3 is empty")
            XCTAssertFalse(self.viewModel.invitedFriends.isEmpty, "Invited friends data 3 is empty")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testFetchFriendsData4() {
        let expectation = XCTestExpectation(description: "Fetch friends data 4")

        viewModel.fetchFriendsData(from: "https://dimanyen.github.io/friend4.json") { success in
            XCTAssertTrue(success, "Failed to fetch friends data 4")
            XCTAssertTrue(self.viewModel.friends.isEmpty, "Friends data 4 is not empty")
            XCTAssertTrue(self.viewModel.invitedFriends.isEmpty, "Invited friends data 4 is not empty")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }
}
