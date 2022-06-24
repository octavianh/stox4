//
//  CurrencyUtils.swift
//  CashStock
//
//  Created by O on 2022-06-15.
//

import Foundation

struct CurrencyUtils {
    static func priceString(cents: Int, currencyCode: String) -> String {
        var maximumFractionDigits = 2
        switch currencyCode {
        // fun fact: Oman uses three decimal points in its currency for some reason
        // There might be some other countries that do this, I'm not sure - hence the switch statement as opposed to a simple `if`
        case "OMR":
            maximumFractionDigits = 3
        default:
            maximumFractionDigits = 2
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currencyCode
        formatter.maximumFractionDigits = maximumFractionDigits
        let amount = NSNumber(value: cents/100)
        guard let result = formatter.string(from: amount) else {
            //TODO: log error here
            return ""
        }
        return result
    }
}
