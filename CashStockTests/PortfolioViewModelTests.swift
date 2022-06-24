//
//  CashStockTests.swift
//  CashStockTests
//
//  Created by O on 2022-06-13.
//

import XCTest
@testable import CashStock

class PortfolioViewModelTests: XCTestCase {
    var mockDelegate: MockDelegate!
    var mockFetcher: MockPortfolioFetcher!
    var sut: PortfolioViewModel!
    
    override func setUpWithError() throws {
        mockDelegate = MockDelegate()
        mockFetcher = MockPortfolioFetcher()
        sut = PortfolioViewModel(delegate: mockDelegate,
                                 cloudService: mockFetcher,
                                 pollingInterval: 10) //set it to ten so the timer doesn't fire
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_pollUpdatesStocksProperly() throws {
        let expectation = XCTestExpectation(description: "strocks updated")
        mockDelegate.updateCompletion = { expectation.fulfill() }
        mockFetcher.result = [Stock(ticker: "ABC", name: "Abc", currency: "USD", quantity: nil, currentPriceCents: 123, currentPriceTimestamp: Date())]
        
        sut.startPolling()
        sut.stopPolling()
        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_pollUpdatesStocksProperly_EmptyCase() throws {
        mockDelegate.resultIsEmpty = false
        mockFetcher.result = []
        
        sut.startPolling()
        sut.stopPolling()
        XCTAssertTrue(mockDelegate.resultIsEmpty)
    }
    
    func test_pollReturnsError() throws {
        mockFetcher.result = nil //mocks no result returned from cloud
        let expectation = XCTestExpectation(description: "error returned")
        mockDelegate.errorCompletion = { error in
            expectation.fulfill()
        }
        sut.startPolling()
        sut.stopPolling()
        wait(for: [expectation], timeout: 0.1)
    }
}

class MockPortfolioFetcher: PortfolioDataFetching {
    var result:[Stock]?
    func fetchPortfolioData(onDone completion: @escaping (Result<[Stock],Error>)->()) {
        if let result = result {
            completion(.success(result))
        } else {
            completion(.failure(NetworkError.malformedURL))
        }
    }
    
    func cancelPortfolioDataFetch() {}
}

class MockDelegate: PortfolioViewModelDelegate {
    var updateCompletion:(()->())?
    var errorCompletion:((Error)->())?
    var resultIsEmpty:Bool = false
    func onPortfolioUpdate(emptyResult:Bool) {
        resultIsEmpty = emptyResult
        updateCompletion?()
    }
    func onPortfolioError(error:Error) {
        errorCompletion?(error)
    }
}
