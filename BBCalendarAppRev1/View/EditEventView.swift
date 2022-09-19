//
//  EditEventView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/19.
//

import SwiftUI

struct EditEventView: View {
    
    @EnvironmentObject private var eventManager: EventManager
    @Environment(\.dismiss) var dismiss
    
    @Binding var id: UUID
    
    @State var eventTitle: String = ""
    @State var eventDescription: String = ""
    @State var eventDate: Date = Date()
    
    var body: some View {
        NavigationView {
            
            List{
                
                Section {
                    TextField(eventTitle, text: $eventTitle)
                } header: {
                     Text("Event Title")
                }
                
                Section {
                    TextField(eventDescription, text: $eventDescription)
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
            .onChange(of: eventManager.isRefreshing) { newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    
                    eventManager.filteredEvents = []
                    
                    eventManager.allEvents = SQLiteCommands.getEvents()
                    eventManager.filterTodayEvents()
                }
            }
            .onAppear {
                
                let preEditedEvent: Event = SQLiteCommands.getEvent(idValue: self.id)
                
                self.eventTitle = preEditedEvent.eventTitle
                self.eventDescription = preEditedEvent.eventDescription
                self.eventDate = preEditedEvent.eventDateFrom
            }
            .toolbar {
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("Save") {
                        
                        DispatchQueue.main.async {
                            let event = Event(id: self.id, eventTitle: self.eventTitle, eventDescription: self.eventDescription, eventCategory: "", eventColorCode: "", eventDateFrom: self.eventDate, eventDateTo: self.eventDate, isCompleted: false)
                            
                            SQLiteCommands.updateEvent(eventValue: event)

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

//struct EditEventView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditEventView()
//    }
//}
