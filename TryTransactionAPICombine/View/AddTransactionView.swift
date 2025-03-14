//
//  AddTransactionView.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import SwiftUI

struct AddTransactionView: View {
    @State private var category: String = ""
    @State private var type: String = ""
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: String = ""
    
    @Environment(\.dismiss) var dismiss
    @Environment(APIConnect.self) var apiConnect
    
    private func addTransaction() {
        apiConnect.addTransaction(category: category, type: type, amount: Double(amount) ?? 0, description: description, date: date)
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Text("Add Transaction")
                    .font(.largeTitle.weight(.bold))
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.red)
                }
            }
            .padding(.horizontal)
            
            Form {
                TextField("Category", text: $category)
                TextField("Type", text: $type)
                TextField("Amount", text: $amount)
                TextField("Description", text: $description)
                TextField("Date", text: $date)
                
                Button {
                    addTransaction()
                } label: {
                    Text("Add")
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
        }
    }
}

#Preview {
    AddTransactionView()
        .environment(APIConnect())
}
