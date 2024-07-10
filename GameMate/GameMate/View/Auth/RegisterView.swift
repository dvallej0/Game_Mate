//
//  RegisterView.swift
//  GameMate
//
//  Created by Daniel on 12/21/23.
//

import SwiftUI

struct RegisterView: View {
    @State private var startRegistrationFlow = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            VStack{
                
                Text("Game Mate")
                    .font(.largeTitle)
                    .padding()
                
                BrandingImage()
                Text("Register")
                    .font(.largeTitle)
                    .padding()
                
                VStack(spacing: 32){
                    GameMateinputField(imageName: "envelope", placeholderText: "email", text:  $viewModel.email)
                    GameMateinputField(imageName: "person", placeholderText: "name", text: $viewModel.name)
                    GameMateinputField(imageName: "lock", placeholderText: "password", text: $viewModel.password, isSecureField: true)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                
                Button{
                    Task{
                        try await viewModel.register(){
                            startRegistrationFlow.toggle()
                        }
                    }
                } label: {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .background(Color(.systemBlue))
                        .clipShape(Capsule())
                }
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 0)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                Spacer()
                Text("This App is created by Daniel Vallejo and Anissa Braca for the purpose of finding your Game Mate match.")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
                
                Button{
                    presentationMode.wrappedValue.dismiss()
                }label: {
                    HStack{
                        Text("Already Register?")
                            .font(.footnote)
                        Text("Login")
                            .font(.footnote)
                            .bold()
                    }
                }
                
                .padding(.bottom, 48)
            }
            
            if $viewModel.isLoading.wrappedValue{
                LoadingOverlayView()
            }
        }
        .alert(viewModel.errorEvent.content, isPresented: $viewModel.errorEvent.display){
            Button("OK", role: .cancel) { }
        }
        .navigationDestination(isPresented: $startRegistrationFlow){
            RegisterImageView()
                .navigationBarBackButtonHidden()
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
