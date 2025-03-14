//
//  TransactionsView.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import SwiftUI

struct TransactionsView: View {
    @Environment(APIConnect.self) var apiConnect
    
    @State private var showSheet: Bool = false
    
    private func loadTransactions() {
        apiConnect.getTransactions()
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if apiConnect.transactions.isEmpty {
                    ContentUnavailableView("No Transactions", systemImage: "list.dash.header.rectangle")
                } else {
                    List(apiConnect.transactions) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                    .listStyle(.plain)
                    .navigationTitle("Transactions")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }

                }
            }
        }
        .onAppear {
            loadTransactions()
        }
        .sheet(isPresented: $showSheet, onDismiss: {
            loadTransactions()
        }) {
            AddTransactionView()
        }
    }
}

#Preview {
    TransactionsView()
        .environment(APIConnect(isPreview: true))
}

struct TransactionRow: View {
    let transaction: Transaction
    
    var isExpense: Bool {
        transaction.type == "expense"
    }
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text(transaction.description.capitalized)
                    .fontWeight(.bold)
                Text("Category: \(transaction.category.capitalized)")
                Text("Type: \(transaction.type.capitalized)")
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(transaction.amount, format: .currency(code: "THB"))")
                    .foregroundStyle(isExpense ? .red : .green)
                
                Text(transaction.date)
            }
        }
    }
}

extension DateFormatter {
    static var dateOnlyFormat: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
