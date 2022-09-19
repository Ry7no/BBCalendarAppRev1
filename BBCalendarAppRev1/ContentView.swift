//
//  ContentView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/8.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @StateObject private var loginManager = LoginManager()
    @StateObject private var eventManager = EventManager()
//    @StateObject private var sqliteManager = SqliteManager()
    
    @AppStorage("logStatus") var logStatus: Bool = false
    
    var body: some View {
        
        Group {
            if logStatus {
                HomeView()
                    .environmentObject(eventManager)
                    
            } else {
                IntroView()
//                    .onOpenURL { url in
//                        GIDSignIn.sharedInstance.handle(url)
//                    }
                    
//                    .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)

            }
        }
        .environmentObject(loginManager)
//        .environmentObject(sqliteManager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
