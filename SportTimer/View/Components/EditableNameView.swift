//
//  EditableNameView.swift
//  SportTimer
//
//  Created by Алексей Авер on 08.07.2025.
//

import SwiftUI

struct EditableNameView: View {
    @AppStorage("username") private var username: String = "User"
    @State private var isEditing = false
    @State private var tempName = ""

    var body: some View {
        HStack {
            if isEditing {
                TextField("Name", text: $tempName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        if tempName.isEmpty {
                            tempName = "User"
                        }
                        username = tempName
                        isEditing = false
                    }
            } else {
                Text(username)
                    .font(.headline)
                    .onTapGesture {
                        tempName = username
                        isEditing = true
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EditableNameView()
}
