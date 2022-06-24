//
//  PortfolioTableViewCell.swift
//  CashStock
//
//  Created by O on 2022-06-15.
//

import UIKit

class PortfolioTableViewCell: UITableViewCell {
    
    static let cellIdentifier = "stockCellID"
    
    @IBOutlet var price: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var ticker: UILabel!
    
    func configure(for stock: Stock) {
        price.text = CurrencyUtils.priceString(cents: stock.currentPriceCents,
                                               currencyCode: stock.currency)
        name.text = stock.name
        ticker.text = stock.ticker
    }
}
