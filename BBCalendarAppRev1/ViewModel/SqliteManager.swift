//
//  DBManager.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/17.
//

import Foundation
import SwiftUI
import SQLite
import SQLite3

class SQLiteDatabase {
    
    static let shared = SQLiteDatabase()
    
    var db: Connection?
    
    private init() {
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("events").appendingPathExtension("sqlite3")
            
            db = try Connection(fileUrl.path)
        } catch {
            print("Creating connection to db error: \(error.localizedDescription)")
        }
    }
    
    func creatTable() {
        SQLiteCommands.createTable()
    }
    
    func deleteTable() {
        
        let fileManager = FileManager.default
        
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("events").appendingPathExtension("sqlite3")
            try fileManager.removeItem(at: fileUrl as URL)
            print("SQLite events table delete")
        } catch {
            print("Error on Delete table")
        }
 
    }
}

class SQLiteCommands {

    static var eventsTable = Table("eventsTable")
    
    static let id = Expression<UUID>("id")
    static let eventTitle = Expression<String>("eventTitle")
    static let eventDescription = Expression<String>("eventDescription")
    static let eventCategory = Expression<String>("eventCategory")
    static let eventColorCode = Expression<String>("eventColorCode")
    static let eventDateFrom = Expression<Date>("eventDateFrom")
    static let eventDateTo = Expression<Date>("eventDateTo")
    static let isCompleted = Expression<Bool>("isCompleted")
    
    @Published var fetchedEvents: [Event] = []
    
    static func deleteAllData() {
        guard let db = SQLiteDatabase.shared.db else {
            print("DB connection error")
            return
        }
        
        do {
            try db.scalar("DELETE FROM eventsTable")
//            try db.run(eventsTable.delete())
        } catch {
            print("Table already exists: \(error.localizedDescription)")
        }
    }
    
    static func createTable() {
        guard let db = SQLiteDatabase.shared.db else {
            print("DB connection error")
            return
        }
        
        do {
            try db.run(eventsTable.create(ifNotExists: true) { event in
                event.column(id, primaryKey: true)
                event.column(eventTitle)
                event.column(eventDescription)
                event.column(eventCategory)
                event.column(eventColorCode)
                event.column(eventDateFrom)
                event.column(eventDateTo)
                event.column(isCompleted)
            })
        } catch {
            print("Table already exists: \(error.localizedDescription)")
        }
    }
    
    static func addEvent(event: Event) -> Bool? {
        guard let db = SQLiteDatabase.shared.db else {
            print("Datastore connection error")
            return nil
        }
        
        do {
            try db.run(eventsTable.insert(id <- event.id,
                                          eventTitle <- event.eventTitle,
                                          eventDescription <- event.eventDescription,
                                          eventCategory <- event.eventCategory,
                                          eventColorCode <- event.eventColorCode,
                                          eventDateFrom <- event.eventDateFrom,
                                          eventDateTo <- event.eventDateTo,
                                          isCompleted <- event.isCompleted))
            return true
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Add event failed: \(message), in \(statement)")
            return false
        } catch let error {
            print("Add failed: \(error.localizedDescription)")
            return false
        }
    }
    
    static func getEvent(idValue: UUID) -> Event {
        guard let db = SQLiteDatabase.shared.db else {
            print("Datastore connection error")
            return Event()
        }
        
        var eventModel = Event()
        
        do {
            
            let event: AnySequence<Row> = try db.prepare(eventsTable.filter(id == idValue))
                
            try event.forEach({ (rowValue) in
                
                eventModel.id = try rowValue.get(id)
                eventModel.eventTitle = try rowValue.get(eventTitle)
                eventModel.eventDescription = try rowValue.get(eventDescription)
                eventModel.eventColorCode = try rowValue.get(eventColorCode)
                eventModel.eventDateFrom = try rowValue.get(eventDateFrom)
            })
            
        } catch {
            print("Fetch event error: \(error.localizedDescription)")
        }
        return eventModel
    }
    
    static func updateEvent(eventValue: Event) -> Bool? {
        guard let db = SQLiteDatabase.shared.db else {
            print("Datastore connection error")
            return nil
        }
        
        let event = eventsTable.filter(id == eventValue.id).limit(1)
        
        do {
            if try db.run(event.update(eventTitle <- eventValue.eventTitle,
                                       eventDescription <- eventValue.eventDescription,
                                       eventCategory <- eventValue.eventCategory,
                                       eventColorCode <- eventValue.eventColorCode,
                                       eventDateFrom <- eventValue.eventDateFrom,
                                       eventDateTo <- eventValue.eventDateTo,
                                       isCompleted <- eventValue.isCompleted)) > 0 {
                return true
            } else {
                print("Could not update event as not found")
                return false
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("Update event failed: \(message), in \(statement)")
            return false
        } catch let error {
            print("Updating failed: \(error.localizedDescription)")
            return false
        }
    }
    
    static func getEvents() -> [Event] {
        guard let db = SQLiteDatabase.shared.db else {
            print("Datastore connection error")
            return []
        }
        
        var eventArray = [Event]()
        
        eventsTable = eventsTable.order(id)
        
        do {
            for event in try db.prepare(eventsTable) {
                let idValue = event[id]
                let eventTitleValue = event[eventTitle]
                let eventDescriptionValue = event[eventDescription]
                let eventCategoryValue = event[eventCategory]
                let eventColorCodeValue = event[eventColorCode]
                let eventDateFromValue = event[eventDateFrom]
                let eventDateToValue = event[eventDateTo]
                let isCompletedValue = event[isCompleted]
                
                let eventObj = Event(id: idValue, eventTitle: eventTitleValue, eventDescription: eventDescriptionValue, eventCategory: eventCategoryValue, eventColorCode: eventColorCodeValue, eventDateFrom: eventDateFromValue, eventDateTo: eventDateToValue, isCompleted: isCompletedValue)
                
                eventArray.append(eventObj)
                
            }
        } catch {
            print("Fetch data error: \(error.localizedDescription)")
        }
        return eventArray
    }
    
    static func deleteEvent(idValue: UUID) {
        guard let db = SQLiteDatabase.shared.db else {
            print("Datastore connection error")
            return
        }
        
        do {

            let event = eventsTable.filter(id == idValue).limit(1)
            try db.run(event.delete())
            
            
        } catch {
            print("Delete Event error: \(error.localizedDescription)")
        }
        
        
//        eventManager.allEvents = SQLiteCommands.getEvents()
//        eventManager.filterTodayEvents()
//        getEvents()

    }
    
}

//class SqliteManager: ObservableObject {
//
//    static let shared = SqliteManager()
//
//    private var db: Connection?
//    private var events: Table!
//
//    private var id: Expression<UUID>!
//    private var eventTitle: Expression<String>!
//    private var eventDescription: Expression<String>!
//    private var eventCategory: Expression<String>!
//    private var eventColorCode: Expression<String>!
//    private var eventDateFrom: Expression<Date>!
//    private var eventDateTo: Expression<Date>!
//    private var isCompleted: Expression<Bool>!
//
//    @State var fetchedEvents: [Event] = []
//
//    init() {
//
//        do {
//
//            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let fileUrl = documentDirectory.appendingPathComponent("events").appendingPathExtension("sqlite3")
//
//            db = try Connection(fileUrl.path)
//
//        } catch {
//            print("Creating connection to db error: \(error.localizedDescription)")
//        }
//    }
//
////    init() {
////        do {
////
////            let path: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
////
////            db = try Connection("\(path)/events.sqlite3")
////            events = Table("events")
////
////            id = Expression<UUID>("id")
////            eventTitle = Expression<String>("eventTitle")
////            eventDescription = Expression<String>("eventDescription")
////            eventCategory = Expression<String>("eventCategory")
////            eventColorCode = Expression<String>("eventColorCode")
////            eventDateFrom = Expression<Date>("eventDateFrom")
////            eventDateTo = Expression<Date>("eventDateTo")
////            isCompleted = Expression<Bool>("isCompleted")
////
////            if (!UserDefaults.standard.bool(forKey: "isDBCreated")) {
////                try! db.run(events.create { event in
////                    event.column(id)
////                    event.column(eventTitle)
////                    event.column(eventDescription)
////                    event.column(eventCategory)
////                    event.column(eventColorCode)
////                    event.column(eventDateFrom)
////                    event.column(eventDateTo)
////                    event.column(isCompleted)
////
////                })
////
////                UserDefaults.standard.set(true, forKey: "isDBCreated")
////            }
////
////
////
////        } catch {
////            print(error.localizedDescription)
////        }
////    }
//
//    func addEvent(event: Event) {
//        do {
//            try db.run(events.insert(eventTitle <- event.eventTitle,
//                                     eventDescription <- event.eventDescription,
//                                     eventCategory <- event.eventCategory,
//                                     eventColorCode <- event.eventColorCode,
//                                     eventDateFrom <- event.eventDateFrom,
//                                     eventDateTo <- event.eventDateTo,
//                                     isCompleted <- event.isCompleted))
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func getEvents() -> [Event] {
//
////        var sqlEvents: [Event] = []
//
//        events = events.order(eventDateFrom.desc)
//
//        do {
//
//            for event in try db.prepare(events) {
//
//                var sqlEvent: Event = Event()
//
//                sqlEvent.id = event[id]
//                sqlEvent.eventTitle = event[eventTitle]
//                sqlEvent.eventDescription = event[eventDescription]
//                sqlEvent.eventCategory = event[eventCategory]
//                sqlEvent.eventColorCode = event[eventColorCode]
//                sqlEvent.eventDateFrom = event[eventDateFrom]
//                sqlEvent.eventDateTo = event[eventDateTo]
//                sqlEvent.isCompleted = event[isCompleted]
//
//                fetchedEvents.append(sqlEvent)
//            }
//            print("@@ events: \(events)")
//        } catch {
//            print(error.localizedDescription)
//        }
//
//        return fetchedEvents
//    }
//}
