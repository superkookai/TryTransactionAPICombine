//
//  Model.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import Foundation

struct LoginRequest: Encodable {
    let username: String
    let password: String
}

struct LoginGrant: Decodable {
    let access_token: String
}

struct Transaction: Decodable, Identifiable {
    let id: Int
    let category: String
    let type: String
    let amount: Double
    let description: String
    let date: String
    let owner_id: Int
}

struct TransactionRequest: Encodable {
    let category: String
    let type: String
    let amount: Double
    let description: String
    let date: String
}
