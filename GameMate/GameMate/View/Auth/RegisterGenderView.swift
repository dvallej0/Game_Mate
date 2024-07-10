//
//  RegisterGenderView.swift
//  GameMate
//
//  Created by Daniel on 1/9/24.
//

import SwiftUI

struct RegisterGenderView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            Text("Step 3 of 6")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding()
            Text("Hey, \(viewModel.currentUser?.name ?? "")")
                .font(.title)
                .padding()
            Text("What are you looking for?")
                .font(.headline)
                .padding()
            
            Divider()
            
            HStack{
                Text("I am a")
                    .padding(.trailing)
                    .frame(width: 150, alignment: .trailing)
                Picker("Choose", selection: $viewModel.gender){
                    ForEach(GameMateGender.allCases){ gender in
                        switch gender{
                        case GameMateGender.man: Text("Man")
                        case GameMateGender.woman: Text("Woman")
                        case GameMateGender.unspecified: Text("Unspecified")
                    }
                   
                    }
                }
                .frame(width: 150, alignment: .leading)
                
            }
            
            Divider()
            
            HStack{
                Text("Looking for")
                    .padding(.trailing)
                    .frame(width: 150, alignment: .trailing)
                Picker("Choose", selection: $viewModel.preference){
                    ForEach(GameMateGender.allCases){ gender in
                        switch gender{
                        case GameMateGender.man: Text("Men")
                        case GameMateGender.woman: Text("Women")
                        case GameMateGender.unspecified: Text("Any")
                    }
                   
                    }
                }
                .frame(width: 150, alignment: .leading)
                
            }
            NavigationLink{
                RegisterBioView()
                    .navigationBarBackButtonHidden()
            }label: {
                Text("Next")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemBlue))
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding()
            Button{
                viewModel.skipRegistrationFlow()
                dismiss()
            }label: {
                Text("Skip")
            }
            .foregroundColor(.gray)
            
            Spacer()
        }
    }
}

struct RegisterGenderView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterGenderView()
            .environmentObject(AuthViewModel())
    }
}
