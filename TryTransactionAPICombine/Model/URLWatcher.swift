//
//  URLWatcher.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 25/03/2568.
//

import Foundation

struct URLWatcher: AsyncSequence, AsyncIteratorProtocol {
    let url: URL
    let delay: Int
    let token: String
    private var comparisonData: Data?
    private var isActive = true

    init(url: URL, delay: Int, token: String) {
        self.url = url
        self.delay = delay
        self.token = token
    }

    mutating func next() async throws -> Data? {
        // Once we're inactive always return nil immediately
        guard isActive else { return nil }

        if comparisonData == nil {
            // If this is our first iteration, return the initial value
            comparisonData = try await fetchData()
        } else {
            // Otherwise, sleep for a while and see if our data changed
            while true {
                try await Task.sleep(for: .seconds(delay))
                let latestData = try await fetchData()

                if latestData != comparisonData {
                    // New data is different from previous data,
                    // so update previous data and send it back
                    comparisonData = latestData
                    break
                }
            }
        }

        if comparisonData == nil {
            isActive = false
            return nil
        } else {
            return comparisonData
        }
    }

    private func fetchData() async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        return data
    }

    func makeAsyncIterator() -> URLWatcher {
        self
    }
}
