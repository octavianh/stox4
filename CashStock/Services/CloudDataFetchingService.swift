//
//  CloudDataFetchingService.swift
//  CashStock
//
//  Created by O on 2022-06-14.
//

import Foundation

class CloudDataFetchingService {
    weak var task: URLSessionTask?

    func makeNetworkRequest(_ urlString: String, completion: @escaping (Result<Data,Error>)->()) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(NetworkError.noData))
                }
                if let error = error  {
                    completion(.failure(error))
                }
            }
            if self.task != nil {
                self.task?.cancel()
            }
            self.task = task
            task.resume()
        } else {
            completion(.failure(NetworkError.malformedURL))
        }
    }
}
