//
//  LoginView.swift
//  TryTransactionAPICombine
//
//  Created by Weerawut Chaiyasomboon on 13/03/2568.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    
    @Environment(APIConnect.self) var apiConnect
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Form {
                TextField("Username", text: $username)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                SecureField("Password", text: $password)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                
                Button {
                    apiConnect.login(username: self.username, password: self.password)
                } label: {
                    Text("Login")
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)

            }
        }
    }
}

#Preview {
    LoginView()
        .environment(APIConnect())
}
