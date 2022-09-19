//
//  LoginView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/8.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase

struct LoginView: View {
    
    @EnvironmentObject private var loginManager: LoginManager
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {

            VStack(alignment: .center, spacing: 20) {
                
                Image(systemName: "triangle")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color("Purple2"))

                Text("Welcome Back")
                    .foregroundColor(.primary)
                    .font(.system(size: 40))
                    .fontWeight(.bold)
                    .lineSpacing(6)

                 Text("Login to continue")
                    .foregroundColor(.secondary)
                    .font(.system(size: 20))
                    .fontWeight(.semibold)
                    .lineSpacing(6)
 
            }
            .padding(.top, 40)
            .padding(.horizontal, 40)
            
            VStack(alignment: .leading, spacing: 20) {
                
                CustomTextField(hint: "+886 989507295", text: $loginManager.mobileNo)
                    .disabled(loginManager.showOTPField)
                    .opacity(loginManager.showOTPField ? 0.4 : 1)
                    .overlay(alignment: .trailing, content: {
                        Button("Change") {
                            withAnimation(.easeInOut){
                                loginManager.showOTPField = false
                                loginManager.otpCode = ""
                                loginManager.CLIENT_CODE = ""
                            }
                        }
                        .font(.system(size: 12))
                        .foregroundColor(.indigo)
                        .padding(.trailing, 12)
                        .opacity(loginManager.showOTPField ? 1 : 0)
                    })
                    .padding(.top, 40)
                
                CustomTextField(hint: "OTP Code", text: $loginManager.otpCode)
                    .disabled(!loginManager.showOTPField)
                    .opacity(!loginManager.showOTPField ? 0.4 : 1)
                    .padding(.top, 10)
                
                Button (action: loginManager.showOTPField ? loginManager.verifyOTPCode : loginManager.getOTPCode) {
                    
                    HStack(spacing: 15) {
                        Text(loginManager.showOTPField ? "Verify Code" : "Get Code")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        
                        Image(systemName: "line.diagonal.arrow")
                            .font(.system(size: 16))
                            .rotationEffect(.init(degrees: 45))
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 25)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color("Purple3"))
                    }
                    
                }
                .padding(.top, 10)
                
                ZStack {
                    
                    Divider()
                        .foregroundColor(.purple)
                    
                    Text("(OR)")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 15)
                        .background {
                            Rectangle().fill(Color.white)
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 30)
                .padding(.bottom, 20)
//                    .padding(.horizontal)
                
                GoogleButton()
                .overlay {
                    if let clientID = FirebaseApp.app()?.options.clientID {
                        GoogleSignInButton {
                            GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()){ user,error in
                                
                                if let error = error {
                                    loginManager.isLoading = false
                                    print(error.localizedDescription)
                                    return
                                }
                                
                                if let user = user {
                                    loginManager.logGoogleUser(user: user)
                                }
                            }
                        }
                        .blendMode(.overlay)
                        
                    }
                }
                .clipped()
                
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 40)
            .alert(loginManager.errorMessage, isPresented: $loginManager.showError) {
                
            }
            
        }
        .overlay(
            ZStack {
                if loginManager.isLoading {
                    Color.black.opacity(0.25).ignoresSafeArea()
                    
                    ProgressView()
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .cornerRadius(10)
                }
            }
        )

    }
    
    @ViewBuilder
    func GoogleButton() -> some View {
        
        HStack {
            
            Image("googleLogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .frame(height: 45)
            
            Text("Google Sign in")
                .font(.system(size: 14))
                .lineLimit(1)
            
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.black)
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
