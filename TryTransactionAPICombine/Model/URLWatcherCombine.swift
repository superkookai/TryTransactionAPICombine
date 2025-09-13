//
//  URLWatcherCombine.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/09/2568.
//

//MARK: - NOT TEST YET -- 13/09/2025 FROM ChatGPT

import Combine
import Foundation

/// A Combine publisher that periodically polls a URL
/// and emits a new `Data` value when the remote content changes.
final class URLWatcherPublisher {
    private let url: URL
    private let delay: TimeInterval
    private let token: String
    
    init(url: URL, delay: TimeInterval, token: String) {
        self.url = url
        self.delay = delay
        self.token = token
    }
    
    func publisher() -> AnyPublisher<Data, Error> {
        // Timer publishes at fixed interval
        Timer.publish(every: delay, on: .main, in: .default)
            .autoconnect()
        // First value immediately, not just after delay
            .prepend(Date())
        // For each tick, perform a network request
            .flatMap { [url, token] _ in
                Self.fetchData(url: url, token: token)
                // Ensure any request error travels downstream as .failure
                    .catch { error in Fail<Data, Error>(error: error) }
            }
        // Only emit if the fetched data is different from the previous
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    private static func fetchData(url: URL, token: String) -> AnyPublisher<Data, Error> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                guard let httpResponse = output.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .eraseToAnyPublisher()
    }
}

import SwiftUI

struct ContentView2: View {
    @State private var cancellable: AnyCancellable?
    @State private var dataString = "Waiting…"
    
    var body: some View {
        Text(dataString)
            .onAppear {
                let watcher = URLWatcherPublisher(
                    url: URL(string: "https://api.example.com/data")!,
                    delay: 5,
                    token: "YOUR_TOKEN"
                )
                
                cancellable = watcher.publisher()
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            if case let .failure(error) = completion {
                                print("Error:", error)
                            }
                        },
                        receiveValue: { newData in
                            // Update UI when the data really changes
                            dataString = String(decoding: newData, as: UTF8.self)
                        }
                    )
            }
            .onDisappear {
                cancellable?.cancel()
            }
    }
}

