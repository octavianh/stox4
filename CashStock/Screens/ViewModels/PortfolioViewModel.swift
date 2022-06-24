//
//  PortfolioViewModel.swift
//  CashStock
//
//  Created by O on 2022-06-14.
//

import Foundation

class PortfolioViewModel {
    var stocks: [Stock] = []
    weak var delegate: PortfolioViewModelDelegate?
    
    private var cloudService: PortfolioDataFetching
    private var pollingTimer: Timer?
    private var isCurrentlyFetching: Bool = false
    private var pollingInterval: TimeInterval = 0
    
    init(delegate: PortfolioViewModelDelegate?,
         cloudService: PortfolioDataFetching = PortfolioDataFetchingService(),
         pollingInterval: TimeInterval = CashStockConstants.pollingInterval) {
        self.cloudService = cloudService
        self.delegate = delegate
        self.pollingInterval = pollingInterval
    }
    
    // actions
    @objc
    private func fetchStocks() {
        print("\(Date()): fetchStocks called")
        guard isCurrentlyFetching == false else {
            return
        }
        isCurrentlyFetching = true
        print("\(Date()): fetching stocks")
        cloudService.fetchPortfolioData { result in
            self.isCurrentlyFetching = false
            switch result {
            case let .success(portfolioData):
                self.stocks = portfolioData
                self.delegate?.onPortfolioUpdate(emptyResult: self.stocks.count < 1)
            case let .failure(error):
                self.stocks = []
                self.delegate?.onPortfolioError(error: error)
            }
        }
    }
    
    func startPolling() {
        fetchStocks()
        if pollingTimer == nil {
            pollingTimer = Timer.scheduledTimer(timeInterval: pollingInterval,
                                                target: self,
                                                selector: #selector(fetchStocks),
                                                userInfo: nil,
                                                repeats: true)
            RunLoop.current.add(pollingTimer!, forMode: .common)
        }
    }
    
    func stopPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
        cloudService.cancelPortfolioDataFetch()
    }
}
