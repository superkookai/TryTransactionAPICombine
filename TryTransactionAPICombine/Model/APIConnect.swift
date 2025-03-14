//
//  APIConnect.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import Foundation
import Combine

@MainActor
@Observable
class APIConnect {
    var token: String?
    var transactions: [Transaction] = []
    var cancellable: Set<AnyCancellable> = []
    
    init(isPreview: Bool = false) {
        if isPreview {
            self.transactions = [Transaction(id: 1, category: "entertainment", type: "expense", amount: 120, description: "See Movie", date: "2025-03-15", owner_id: 3)]
        } else {
            self.transactions = []
        }
    }
    
    func login(username: String, password: String) {
        let baseURL = "http://127.0.0.1:8000/auth/get/token"
        guard let url = URL(string: baseURL) else {
            print("Error bad url")
            return
        }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.httpMethod = "POST"
        let loginRequest = LoginRequest(username: username, password: password)
        let encodedLogin = try? JSONEncoder().encode(loginRequest)
        request.httpBody = encodedLogin
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: LoginGrant.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Login Success")
                case .failure(let error):
                    print("Error Login: \(error)")
                }
            } receiveValue: { loginGrant in
                self.token = loginGrant.access_token
            }
            .store(in: &cancellable)
    }
    
    
    func getTransactions() {
        let baseURL = "http://127.0.0.1:8000/transaction/"
        guard let url = URL(string: baseURL) else {
            print("Error bad url")
            return
        }
        
        guard let token = self.token else {
            print("No access token")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Get transactions")
                case .failure(let error):
                    print("Error get transactions: \(error)")
                }
            } receiveValue: { transactions in
                self.transactions = transactions
            }
            .store(in: &cancellable)

    }
    
    func addTransaction(category: String, type: String, amount: Double, description: String, date: String) {
        let baseURL = "http://127.0.0.1:8000/transaction/create"
        guard let url = URL(string: baseURL) else {
            print("Error bad url")
            return
        }
        
        guard let token = self.token else {
            print("No access token")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let transactionRequest = TransactionRequest(category: category, type: type, amount: amount, description: description, date: date)
        request.httpBody = try? JSONEncoder().encode(transactionRequest)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.response)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("Add transaction success")
                case .failure(_):
                    print("Error add transaction")
                }
            } receiveValue: { response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 else {
                    return
                }
            }
            .store(in: &cancellable)
    }
}
