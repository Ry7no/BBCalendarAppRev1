//
//  IntroView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/8.
//

import SwiftUI

struct IntroView: View {
    
    @State var toLoginView: Bool = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            
            VStack {
                
                Image("introImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height/2 + 10)
                    .background(
                        RoundedRectangle(cornerRadius: 50)
                            .foregroundColor(Color("Purple2"))

                    )
                
                VStack(alignment: .center, spacing: 5) {
                    
                    Text("Discover Your Own")
                        .font(.system(size: 35, weight: .bold))
                    
                    Text("DREAM")
                        .font(.system(size: 40, weight: .bold))
                    
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Diam maecenas mi non sed ut odio. Non, justo, sed facilisi et. Eget viverra urna")
                        .font(.system(size: 15))
                        .padding()
                
                }
                .lineSpacing(5)
                .padding(.horizontal, 15)
                
                Button {
                    self.toLoginView.toggle()
                } label: {
                    Text("CONTINUE")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .padding(.horizontal)
//                        .shadow(color: .purple, radius: 2, x: 2, y: 2)
                }
                .frame(width: UIScreen.main.bounds.width - 50, alignment: .center)
                .background(Color("Purple2").clipShape(RoundedRectangle(cornerRadius: 15)))
                .fullScreenCover(isPresented: $toLoginView) {
                    LoginView()
                        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                }

                
                
            }
            
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
