//
//  VerificationRequestWizardTests.swift
//  AppTests
//
//  Created by Luke Stringer on 02/06/2018.
//

import XCTest
@testable import App

class VerificationRequestWizardTests: XCTestCase {
    
    let scrollName = "lulu_witch"
    let scrollURL = "https://dragcave.net/user/lulu_witch"
    
    static let userID = UInt64(1234);
    let wizard = VerificationRequestWizard(userID: VerificationRequestWizardTests.userID)
    
    // MARK: Start
    
    func testFirstState() {
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    // MARK: Input scroll
    
    func testInputScroll() {
        wizard.inputMessage(scrollName)
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmScroll(url: scrollURL))
    }
    
    func testInputScrollWithNoMessage() {
        wizard.inputMessage("")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    // MARK: Retry scroll
    
    func testRetryInputScrollWithUppercaseN() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("N")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithLowercaseN() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("n")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithNo() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("No")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithBadInput() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("blah")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmScroll(url: scrollURL))
    }
    
    // MARK: Confirm scroll
    
    func testConfirmScrollWithUppercaseY() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Y")
        XCTAssertEqual(wizard.scrollURL, scrollURL)
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testConfirmScrollWithLowercasedY() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("y")
        XCTAssertEqual(wizard.scrollURL, scrollURL)
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testConfirmScrollWithYes() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        XCTAssertEqual(wizard.scrollURL, scrollURL)
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    // MARK: Input forum
    
    func testInputForum() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmForum(forumName: "forum_name"))
    }
    
    func testInputForumWithNoMessage() {
        wizard.inputMessage("")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    // MARK: Retry forum
    
    func testRetryForumScrollWithUppercaseN() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("N")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithLowercaseN() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("n")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithNo() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("No")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithBadInput() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("blah")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmForum(forumName: "forum_name"))
    }
    
    // MARK: Confirm forum
    
    func testConfirmForumWithUppercaseY() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("Y")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.userID, VerificationRequestWizardTests.userID)
            XCTAssertEqual(request.scrollURL, scrollURL)
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
    
    func testConfirmForumWithLowercasedY() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("y")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.userID, VerificationRequestWizardTests.userID)
            XCTAssertEqual(request.scrollURL, scrollURL)
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
    
    func testConfirmForumWithYes() {
        wizard.inputMessage(scrollName)
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("Yes")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.userID, VerificationRequestWizardTests.userID)
            XCTAssertEqual(request.scrollURL, scrollURL)
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
}
