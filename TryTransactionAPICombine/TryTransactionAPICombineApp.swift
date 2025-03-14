//
//  TryTransactionAPICombineApp.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import SwiftUI

@main
struct TryTransactionAPICombineApp: App {
    @State private var apiConnect = APIConnect()
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            if apiConnect.token != nil {
                TransactionsView()
                    .environment(apiConnect)
            } else {
                LoginView()
                    .environment(apiConnect)
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                print("App in Background")
            case .inactive:
                print("App in Inactive")
            case .active:
                if apiConnect.token != nil {
                    apiConnect.getTransactions()
                }
            @unknown default:
                fatalError("Unknown happen")
            }
        }
    }
}
