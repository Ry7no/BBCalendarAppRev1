//
//  NewEvent.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/16.
//

import SwiftUI

struct NewEventView: View {
    
    @EnvironmentObject private var eventManager: EventManager
    
//    @StateObject private var sqliteManager = SqliteManager()
//    @EnvironmentObject private var sqliteManager: SqliteManager
    
    
    @Environment(\.dismiss) var dismiss
//    @Environment(\.self) var env
    
    @State var eventTitle: String = ""
    @State var eventDescription: String = ""
    @State var eventDate: Date = Date()
    
//    @Environment(\.managedObjectContext) var context
    
    var body: some View {
        NavigationView {
            
            List{
                
                Section {
                    TextField("Go to work", text: $eventTitle)
                } header: {
                     Text("Event Title")
                }
                
                Section {
                    TextField("Nothing", text: $eventDescription)
                } header: {
                     Text("Event Description")
                }
                
                Section {
                    DatePicker("", selection: $eventDate)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                } header: {
                     Text("Event Date")
                }
                
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add New Event")
            .navigationBarTitleDisplayMode(.inline)
            .interactiveDismissDisabled()
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Save") {
                        
//                        var event = Event(eventTitle: "", eventDescription: "", eventCategory: "", eventColorCode: "", eventDateFrom: Date(), eventDateTo: Date())
//                        event.eventTitle = eventTitle
//                        event.eventDescription = eventDescription
//                        event.eventDateFrom = eventDate
                        
                        
                        DispatchQueue.main.async {
                            let event = Event(eventTitle: eventTitle, eventDescription: eventDescription, eventCategory: "", eventColorCode: "", eventDateFrom: eventDate, eventDateTo: eventDate, isCompleted: false)

                            createNewEvent(eventValues: event)
                            
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
    
    func createNewEvent(eventValues: Event) {
        let eventAdded = SQLiteCommands.addEvent(event: eventValues)
        
        if eventAdded == true {
            dismiss()
        } else {
            print("Error when adding")
        }
    }
}

struct NewEvent_Previews: PreviewProvider {
    static var previews: some View {
        NewEventView()
    }
}
