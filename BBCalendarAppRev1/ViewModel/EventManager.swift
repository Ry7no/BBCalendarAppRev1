//
//  EventManager.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/13.
//

import SwiftUI

class EventManager: ObservableObject {
    
    
//    @ObservedObject var sqliteManager = SqliteManager()
    
//    @Published var fakeEvents: [Event] = [
//
//        Event(eventTitle: "Meeting", eventDescription: "Meeting with Boss", eventCategory: "1", eventColorCode: "1", eventDateFrom: DateManager.shared.string14ToDate(dateStr: "20220916003000"), eventDateTo: DateManager.shared.string14ToDate(dateStr: "20220916023000")),
//        Event(eventTitle: "FFFFF", eventDescription: "Meeting with Boss", eventCategory: "1", eventColorCode: "1", eventDateFrom: DateManager.shared.string14ToDate(dateStr: "20220917003000"), eventDateTo: DateManager.shared.string14ToDate(dateStr: "20220917023000")),
//
//    ]
    
    @Published var allEvents: [Event] = []
    
    @Published var currentWeek: [Date] = []
    @Published var currentDay: Date = Date()
    @Published var filteredEvents: [Event] = []
    @Published var addNewEvent: Bool = false
    
    @Published var eventStartDate: Date = Date()
    @Published var eventColor: String = "BgBlack"
    @Published var isRefreshing: Bool = false
    
    init() {
        fetchCurrentWeek()
        eventStartDate = getNearDate(today: Date())
        allEvents = SQLiteCommands.getEvents()
    }
    
    func updateAllEvents() {
        
        allEvents.removeAll()
        filteredEvents.removeAll()
        
        withAnimation {
            allEvents = SQLiteCommands.getEvents()
            filterTodayEvents()
        }
    }
    
    func filterTodayEvents() {
        
        DispatchQueue.global(qos: .userInteractive).async {

            let calendar = Calendar.current

            let filtered = self.allEvents.filter {
                return calendar.isDate($0.eventDateFrom, inSameDayAs: self.currentDay)
            }
                .sorted { event1, event2 in
                    return event1.eventDateFrom < event2.eventDateFrom
                }

            DispatchQueue.main.async {
                withAnimation {
                    self.filteredEvents = filtered
//                    print(self.filteredEvents)
                }
            }
        }
    }
    
    func fetchCurrentWeek() {
        
        let today = Date()
        let calendar = Calendar.current
        
        let week = calendar.dateInterval(of: .weekOfMonth, for: today)
        
        guard let firstWeekDay = week?.start else { return }
        
        (1...7).forEach { day in
            if let weekday = calendar.date(byAdding: .day, value: day, to: firstWeekDay) {
                currentWeek.append(weekday)
            }
        }
    }
    
    func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(currentDay, inSameDayAs: date)
    }
    
    func isCurrentHour(date: Date) -> Bool {
        
        let calendar = Calendar.current
        
        let dateS = calendar.component(.day, from: date)
        let currentDate = calendar.component(.day, from: Date())
        
        let hour = calendar.component(.hour, from: date)
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour && dateS == currentDate
    }
    
    func extractDate(date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func getColor(colorCode: String) -> Color {
        
        var color: Color = .white
        
        switch colorCode {
        case "1":
            color = Color("BgRed")
        case "2":
            color = Color("BgGreen")
        case "3":
            color = Color("BgBlue")
        default:
            break
        }
        
        return color
    }
    
    func getNearDate(today: Date) -> Date {
        
        let date = DateManager.shared.dateToStringGetDate(date: today)
        var hour = Int(DateManager.shared.dateToStringGetHour(date: today))!
        var min = Int(DateManager.shared.dateToStringGetMin(date: today))!
        
        switch min {
        case 0..<15:
            min = 15
        case 15..<30:
            min = 30
        case 30..<45:
            min = 45
        case 45..<59:
            hour = hour + 1
        default:
            break
        }
        
        
        let now = date + "\(hour)" + "\(min)00"
        let nowDate = DateManager.shared.string14ToDate(dateStr: now)
        print("Date: \(Date())")
        print("now: \(nowDate)")
        return nowDate
        
        
    }
}

