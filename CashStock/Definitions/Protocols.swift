//
//  Protocols.swift
//  CashStock
//
//  Created by O on 2022-06-14.
//

import Foundation

protocol PortfolioDataFetching {
    func fetchPortfolioData(onDone completion: @escaping (Result<[Stock],Error>)->())
    func cancelPortfolioDataFetch()
}

protocol PortfolioViewModelDelegate: AnyObject {
    func onPortfolioUpdate(emptyResult:Bool)
    func onPortfolioError(error:Error)
}
