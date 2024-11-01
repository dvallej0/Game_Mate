//
//  GameMateinputField.swift
//  GameMate
//
//  Created by Daniel on 12/21/23.
//

import SwiftUI

struct GameMateinputField: View {
    let imageName: String
    @State var placeholderText: String
    @Binding var text: String
    var isSecureField: Bool = false
    
    var body: some View {
        VStack {
            HStack(alignment: .top){
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color(.darkGray))
                if isSecureField{
                    SecureField(placeholderText, text: $text)
                } else{
                    TextField(placeholderText, text: $text)
                        .textInputAutocapitalization(.never)
                }
            }
            .padding(4)
            
            Divider()
                .background(Color(.darkGray))
        }
    }
}

struct GameMateinputField_Previews: PreviewProvider {
    static var previews: some View {
        GameMateinputField(imageName:"envelope", placeholderText: "email", text: .constant(""))
            .previewLayout(.sizeThatFits)
    }
}
