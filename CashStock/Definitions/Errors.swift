//
//  Errors.swift
//  CashStock
//
//  Created by O on 2022-06-14.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case malformedURL
    case noData
    
    var errorDescription: String? {
        switch self {
        case .malformedURL:
            return "malformed URL" //these would be localized in a real app
        case .noData:
            return "no data" //these would be localized in a real app
        }
    }
}

enum PortfolioFetchingError: Error, LocalizedError {
    case parsingError
    case networkTimingError
    case emptyData
    
    var errorDescription: String? {
        switch self {
        case .parsingError:
            return "parsing error. Is the URL malformed?" //these would be localized in a real app
        case .networkTimingError:
            return "network timing error" //these would be localized in a real app
        case .emptyData:
            return "There are no tickers in this portfolio"
        }
    }
}
