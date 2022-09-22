//
//  NewEvent.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/16.
//

import SwiftUI

struct EventView: View {
    
    @EnvironmentObject private var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
//    @StateObject private var sqliteManager = SqliteManager()
//    @EnvironmentObject private var sqliteManager: SqliteManager
    
    @Binding var isEditing: Bool
    @Binding var selectedEventId: UUID

//    @State var editedEvent: Event
//    @State var editedEventId: UUID

    @State var eventTitle: String = ""
    @State var eventDescription: String = ""
    @State var eventColorCode: String = "BgRed"
    @State var categoryIndex: Int = 0
    @State var eventCategory: String = "DIRECT SERVICES"
    @State var cateDetailedOptions: [String] = ["Individual Counseling (40-45 min)", "Check-in", "Classroom Lesson", "Responsive Services/Crisis", "Student/Classroom Observation", "Small Group Counseling"]
    @State var detailedOption: String = ""
    @State var eventDateChoose: Int = 15
    @State var eventDateFrom: Date = Date()
    @State var eventDateTo: Date = Date()
    
    let category: [String] = ["DIRECT SERVICES", "COLLABORATION", "COMMUNICATION", "CONSULTATION", "ADMINISTRATIVE/NON-COUNSELING", "SYSTEM PLANNING & PREPARATION"]
    

    var body: some View {
        NavigationView {
            
            List {
                
                Section {
                    TextField("Go to work", text: $eventTitle)
                } header: {
                     Text("Event Title")
                        .foregroundColor(Color(eventColorCode))
                        .bold()
                }
                
                Section {
                    TextField("Nothing", text: $eventDescription)
                } header: {
                     Text("Event Description")
                        .foregroundColor(Color(eventColorCode))
                        .bold()
                }
                
                Section {
                    VStack {
                        Text(category[categoryIndex])
                            .foregroundColor(Color(eventColorCode))
                            .padding(.vertical, 5)
                        
                        Divider()
                        
                        HStack {

                            let colors: [String] = ["BgRed", "BgOrange", "BgYellow", "BgGreen", "BgBlue", "BgBrown"]
                            
                            ForEach(colors.indices, id: \.self){ index in
                                
                                Circle()
                                    .fill(eventColorCode == colors[index] ? Color(colors[index]).opacity(0.8) : Color(colors[index]))
                                    .frame(width: 25, height: 25)
                                    .frame(maxWidth: .infinity)
                                    .background{
                                        if eventColorCode == colors[index] {
                                            Circle()
                                                .strokeBorder(Color(colors[index]), lineWidth: 2)
                                                .padding(-4)
                                            
                                        }
                                    }
                                    .contentShape(Circle())
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            eventColorCode = colors[index]
                                            self.categoryIndex = index
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 5)
                        
                        Divider()
    
                        ForEach (cateDetailedOptions, id:\.self) { option in
                            Text(option)
                                .foregroundColor(detailedOption == option ? .white : .black)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 18)
                                .background(RoundedRectangle(cornerRadius: 6).fill(detailedOption == option ? Color(eventColorCode) : Color.clear))
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        detailedOption = option
                                    }
                                }
                                
                        }
                        .onAppear {
                            createOptions(index: categoryIndex)
                        }
                        .onChange(of: categoryIndex) { _ in
                            createOptions(index: categoryIndex)
                        }
                        .padding(.bottom, 5)
  
                    }
                    
                } header: {
                     Text("Event Category")
                        .foregroundColor(Color(eventColorCode))
                        .bold()
                }
                
//                Section {
//
//
//
//                } header: {
//                    Text("Event Color")
//                        .foregroundColor(Color(eventColorCode))
//                }
                
                Section {
                    DatePicker("", selection: $eventDateFrom, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .accentColor(Color(eventColorCode))
                        .onAppear {
                            eventDateFrom = eventManager.getNearDate(today: Date())
                        }
                    
                } header: {
                     Text("Event Start Date")
                        .foregroundColor(Color(eventColorCode))
                        .bold()
                }
                
                Section {
                    
                    HStack {

                        let minuteArray: [Int] = [15, 30, 45, 60, 90, 120]
                        
                        ForEach(minuteArray, id: \.self){ minutes in
                            
                            Text("\(minutes)")
                                .bold()
                                .foregroundColor(eventDateChoose == minutes ? .white : (eventDateChoose > minutes ? .gray : .black))
//                                .padding(.vertical, 6)
//                                .padding(.horizontal, 6)
                                .frame(width: 30, height: 30)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 6).fill(eventDateChoose == minutes ? Color(eventColorCode) : Color.clear))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6).fill(eventDateChoose > minutes ? Color(eventColorCode).opacity(0.3) : Color.clear)
                                )
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        eventDateChoose = minutes
                                        eventDateTo = eventDateFrom.withAddedMinutes(minutes: Double(minutes))
                                    }
                                }

                        }
                    }
                    .padding(.vertical, 5)
                    
                } header: {
                     Text("Event Period (mins)")
                        .foregroundColor(Color(eventColorCode))
                        .bold()
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle(isEditing ? "Edit Event" : "Add New Event")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .onAppear {
                if isEditing {
                    
                    DispatchQueue.main.async {
                        
                        let preEditedEvent: Event = SQLiteCommands.getEvent(idValue: selectedEventId)
                        
                        self.eventTitle = preEditedEvent.eventTitle
                        self.eventDescription = preEditedEvent.eventDescription
                        self.eventColorCode = preEditedEvent.eventColorCode
                        self.eventDateFrom = preEditedEvent.eventDateFrom
                        self.eventDateTo = preEditedEvent.eventDateTo
                        
                        print("@@eventColorCode: \(eventColorCode)")
                    }
                    
                    
                }
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Save") {
                        
                        DispatchQueue.main.async {
                            let event = Event(id: selectedEventId, eventTitle: eventTitle, eventDescription: eventDescription, eventCategory: "", eventColorCode: eventColorCode, eventDateFrom: eventDateFrom, eventDateTo: eventDateTo, isCompleted: false)
                            
                            if isEditing {
                                editingEvent(eventValues: event)
                            } else {
                                createNewEvent(eventValues: event)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                eventManager.filteredEvents.removeAll()
                                
                                eventManager.allEvents = SQLiteCommands.getEvents()
                                eventManager.filterTodayEvents()
                            }
  
                            eventManager.isRefreshing.toggle()
                        }
                        
                        dismiss()
                    }
                    .disabled(eventTitle == "" || eventDescription == "")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
            }
        }
        
        
    }

    
    func editingEvent(eventValues: Event) {
        let editedEvent = SQLiteCommands.updateEvent(eventValue: eventValues)
        
        if editedEvent == true {
            dismiss()
        } else {
            print("Error when adding")
        }
    }
    
    func createNewEvent(eventValues: Event) {
        let eventAdded = SQLiteCommands.addEvent(event: eventValues)
        
        if eventAdded == true {
            dismiss()
        } else {
            print("Error when adding")
        }
    }
    
    func createOptions(index: Int){
        
        eventCategory = category[categoryIndex]
        
        switch categoryIndex {
        case 0:
            cateDetailedOptions = ["Individual Counseling (40-45 min)", "Check-in", "Classroom Lesson", "Responsive Services/Crisis", "Student/Classroom Observation", "Small Group Counseling"]
        case 1:
            cateDetailedOptions = ["Parent Phone/E-Mail Contact", "Teacher E-mail"]
        case 2:
            cateDetailedOptions = ["Student Support Meeting"]
        case 3:
            cateDetailedOptions = ["Teacher/Staff Consult"]
        case 4:
            cateDetailedOptions = ["Staff Meeting", "Curriculum Meeting", "Staff Duty"]
        case 5:
            cateDetailedOptions = ["Advocacy (Bulltetin, counseling news..)", "Prep Period", "Curriculum Development", "Professional Development", "SAC Meeting or Coordination"]
        default:
            break
        }
    }
}

//struct NewEvent_Previews: PreviewProvider {
//    static var previews: some View {
//        EventView()
//    }
//}

