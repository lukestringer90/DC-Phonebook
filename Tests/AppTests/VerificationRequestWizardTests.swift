//
//  VerificationRequestWizardTests.swift
//  AppTests
//
//  Created by Luke Stringer on 02/06/2018.
//

import XCTest
@testable import App

class VerificationRequestWizardTests: XCTestCase {
    
    let wizard = VerificationRequestWizard()
    
    // MARK: Start
    
    func testFirstState() {
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    // MARK: Input scroll
    
    func testInputScroll() {
        wizard.inputMessage("scroll_name")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmScroll(scrollName: "scroll_name"))
    }
    
    func testInputScrollWithNoMessage() {
        wizard.inputMessage("")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    // MARK: Retry scroll
    
    func testRetryInputScrollWithUppercaseN() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("N")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithLowercaseN() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("n")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithNo() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("No")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestScroll)
    }
    
    func testRetryInputScrollWithBadInput() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("blah")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmScroll(scrollName: "scroll_name"))
    }
    
    // MARK: Confirm scroll
    
    func testConfirmScrollWithUppercaseY() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Y")
        XCTAssertEqual(wizard.scrollName, "scroll_name")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testConfirmScrollWithLowercasedY() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("y")
        XCTAssertEqual(wizard.scrollName, "scroll_name")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testConfirmScrollWithYes() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        XCTAssertEqual(wizard.scrollName, "scroll_name")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    // MARK: Input forum
    
    func testInputForum() {
        wizard.inputMessage("scroll_name")
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
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("N")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithLowercaseN() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("n")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithNo() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("No")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.requestForum)
    }
    
    func testRetryInputForumWithBadInput() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("blah")
        XCTAssertEqual(wizard.state, VerificationRequestWizard.State.confirmForum(forumName: "forum_name"))
    }
    
    // MARK: Confirm forum
    
    func testConfirmForumWithUppercaseY() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("Y")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.scrollName, "scroll_name")
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
    
    func testConfirmForumWithLowercasedY() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("y")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.scrollName, "scroll_name")
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
    
    func testConfirmForumWithYes() {
        wizard.inputMessage("scroll_name")
        wizard.inputMessage("Yes")
        wizard.inputMessage("forum_name")
        wizard.inputMessage("Yes")
        
        if case .complete(let request) = wizard.state {
            XCTAssertEqual(request.scrollName, "scroll_name")
            XCTAssertEqual(request.forumPage, "forum_name")
            XCTAssertNotNil(request.creationDate)
        }
        else {
            XCTFail()
        }
    }
}
