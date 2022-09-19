//
//  LoginManager.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/12.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleSignInSwift


class LoginManager: ObservableObject {

    @Published var mobileNo: String = "886"
    @Published var otpCode: String = ""
    
    @Published var CLIENT_CODE: String = ""
    @Published var showOTPField: Bool = false
    
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var isLoading: Bool = false
    
    @AppStorage("logStatus") var logStatus: Bool = false
    
    func getOTPCode() {
        
        UIApplication.shared.closeKeyboard()
        
        Task {
            do {
//                Auth.auth().settings?.isAppVerificationDisabledForTesting = true
                
                let code = try await PhoneAuthProvider.provider().verifyPhoneNumber("+\(mobileNo)", uiDelegate: nil)
                await MainActor.run(body: {
                    CLIENT_CODE = code
                    withAnimation(.easeInOut) {
                        showOTPField = true
                    }
                })
                
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func verifyOTPCode() {
        
        UIApplication.shared.closeKeyboard()
        
        DispatchQueue.main.async {
            self.isLoading = true
        }
        
        Task {
            do {
                let credential = PhoneAuthProvider.provider().credential(withVerificationID: CLIENT_CODE, verificationCode: otpCode)
                
                try await Auth.auth().signIn(with: credential)

                await MainActor.run(body: {
                    withAnimation {
                        isLoading = false
                        logStatus = true
                    }
                })
                
                
            } catch {
                await handleError(error: error)
            }

        }
        
    }
    
    func logGoogleUser(user: GIDGoogleUser) {
        
        Task {
            do {
                
                DispatchQueue.main.async {
                    self.isLoading = true
                }
                
                guard let idToken = user.authentication.idToken else {return}
                let accessToken = user.authentication.accessToken
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
                
                try await Auth.auth().signIn(with: credential)

                await MainActor.run(body: {
                    withAnimation {
                        isLoading = false
                        logStatus = true
                    }
                })
                
            } catch {
                await handleError(error: error)
            }
        }
    }
    
    func handleError(error: Error) async {
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    
    
}

