//
//  AddEventView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/13.
//

import SwiftUI
import CoreData

struct AddEventView: View {
    
    @EnvironmentObject private var eventManager: EventManager
    @Environment(\.self) var env
    
    @State var startDate = Date()
    
    var body: some View {
        
        VStack {
            
            HStack {
                Text("New Event")
                    .font(.system(size: 25, weight: .bold))

                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 25))
                        .foregroundColor(.gray)

                }
                

            }
            .padding(.horizontal, 20)
            .padding(.top, 40)
            
            ZStack (alignment: .bottom) {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .padding(.horizontal)
                        .accentColor(Color(eventManager.eventColor))
                        .onAppear {
                            startDate = eventManager.getNearDate(today: Date())
                        }

                    HStack(spacing: (UIScreen.main.bounds.width - 60 - (25 * 5)) / 4) {
                        
                        let colors: [String] = ["BgRed", "BgOrange", "BgYellow", "BgGreen", "BgBlue"]
                        
                        ForEach(colors, id: \.self){ color in
                            
                            Circle()
                                .fill(Color(color))
                                .frame(width: 25, height: 25)
                                .background{
                                    if eventManager.eventColor == color {
                                        Circle()
                                            .strokeBorder(Color(color), lineWidth: 2)
                                            .padding(-4)
                                    }
                                }
                                .contentShape(Circle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        eventManager.eventColor = color
                                    }
                                }
                        }
                    }
                    

         
                }
                .background(.white)
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height - 40)
            }
            
            
            Button {
                
            } label: {
                Text("PLAN")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal)
            }
            .frame(width: UIScreen.main.bounds.width - 50, alignment: .center)
            .background(Color(eventManager.eventColor).clipShape(RoundedRectangle(cornerRadius: 15)))
            .padding(.bottom, 30)
            
            
            
        }
        .cornerRadius(10)
        .background(.clear)
        .ignoresSafeArea()
    }
    

}

struct AddEventView_Previews: PreviewProvider {
    static var previews: some View {
        AddEventView()
    }
}
