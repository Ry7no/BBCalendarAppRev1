//
//  CustomTextField.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/12.
//

import SwiftUI

struct CustomTextField: View {
    
    var hint: String
    @Binding var text: String
    @FocusState var isEnabled: Bool
    var contentType: UITextContentType = .telephoneNumber
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            TextField(hint, text: $text)
                .keyboardType(.numberPad)
                .textContentType(contentType)
                .font(.system(size: 16, weight: .medium))
                .padding()
                .focused($isEnabled)
                .background(
                    RoundedRectangle(cornerRadius: 5).fill(Color(uiColor: .lightGray).opacity(0.2))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isEnabled ? Color.purple : Color.gray, lineWidth: isEnabled ? 3 : 1)
                        .animation(.easeInOut(duration: 0.3), value: isEnabled)
                }

        }
    }
}

//struct CustomTextField_Previews: PreviewProvider {
//
//    var text = ""
//
//    static var previews: some View {
//        CustomTextField(hint: "0989507295", text: $text)
//    }
//}
