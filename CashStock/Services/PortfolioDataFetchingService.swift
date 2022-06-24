//
//  PortfolioDataFetchingService.swift
//  CashStock
//
//  Created by O on 2022-06-16.
//

import Foundation

class PortfolioDataFetchingService: CloudDataFetchingService, PortfolioDataFetching {
    func fetchPortfolioData(onDone completion: @escaping (Result<[Stock],Error>)->()) {

        if task != nil {
            guard task?.state == URLSessionTask.State.completed else {
                completion(.failure(PortfolioFetchingError.networkTimingError))
                return
            }
        }
        makeNetworkRequest(Endpoints.portfolioURL){ result in
            switch result {
            case let .success(jsonData):
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                decoder.dateDecodingStrategy = .secondsSince1970
                do {
                    let stockList = try decoder.decode(StockList.self, from: jsonData)
                    let portfolio = stockList.stocks
                    completion(.success(portfolio))
                } catch {
                    completion(.failure(PortfolioFetchingError.parsingError))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    func cancelPortfolioDataFetch() {
        task?.cancel()
    }
}
