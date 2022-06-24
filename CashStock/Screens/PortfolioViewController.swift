//
//  ViewController.swift
//  CashStock
//
//  Created by O on 2022-06-13.
//

import UIKit

class PortfolioViewController: UIViewController {

    enum PortfolioState {
        case loading
        case loaded
        case error(Error)
        case empty
    }
    
    private var viewModel: PortfolioViewModel?
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var errorMessageLabel: UILabel!
    @IBOutlet var errorView: UIView!
    @IBOutlet var errorHeightConstraint: NSLayoutConstraint!
    
    private var currentState: PortfolioState = .loading {
        didSet{
            switch currentState {
            case .loading:
                showMessage("loading...") //todo: localize this
            case .loaded:
                hideMessage()
            case let .error(errorToShow):
                showErrorMessage(errorToShow)
            case .empty:
                self.showErrorMessage(PortfolioFetchingError.emptyData)
                self.viewModel?.stopPolling() // there is no need to keep polling for changes in the price of the tickers since there are no tickers
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = PortfolioViewModel(delegate: self)
        
        title = "My Portfolio"
        
        setupTableView()
        startListeningToBackgroundingEvents()
        
        viewModel?.startPolling()
    }
    
    private func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PortfolioTableViewCell", bundle: nil),
                           forCellReuseIdentifier: PortfolioTableViewCell.cellIdentifier)
    }
    
    // MARK: - Enter & exit background
    //
    private func startListeningToBackgroundingEvents() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
        viewModel?.stopPolling()
    }
    
    @objc func appMovedToForeground() {
        viewModel?.startPolling()
    }
    
    // MARK: - Error
    //
    private func showErrorMessage(_ error: Error) {
        showMessage(error.localizedDescription)
    }
    
    private func showMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessageLabel.text = message
            UIView.animate(withDuration: Animation.errorShowInterval) {
                self.errorView.alpha = 1
                self.errorHeightConstraint.constant = 75 // TODO: fix magic number
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func hideMessage() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Animation.errorShowInterval) {
                self.errorView.alpha = 0
                self.errorHeightConstraint.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
}

// MARK: - Handle Model Update
//
extension PortfolioViewController: PortfolioViewModelDelegate {
    
    func onPortfolioUpdate(emptyResult:Bool) {
        if emptyResult {
            self.currentState = .empty
        } else {
            self.currentState = .loaded
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func onPortfolioError(error: Error) {
        self.currentState = .error(error)
    }
}

// MARK: - UITableViewDelegate
//
extension PortfolioViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
//
extension PortfolioViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.stocks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PortfolioTableViewCell.cellIdentifier, for: indexPath) as! PortfolioTableViewCell
        guard let stock = viewModel?.stocks[indexPath.row] else {
            return cell
        }
        cell.configure(for: stock)
        return cell
    }

}
