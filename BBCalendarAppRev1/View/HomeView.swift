//
//  HomeView.swift
//  BBCalendarAppRev1
//
//  Created by @Ryan on 2022/9/12.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject private var eventManager: EventManager
//    @StateObject var eventManager: EventManager = EventManager()
//    @EnvironmentObject private var sqliteManager: SqliteManager
    @Namespace var animation
    
//    @State var isRefreshing: Bool = false
    
    @State var isEditing: Bool = false
    @State var selectedEventId: UUID = UUID()
//    @State var selectedEvent: Event = Event()
    @State var hasSelected: Bool = false
    
    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {

            LazyVStack(spacing: 15, pinnedViews: [.sectionHeaders]) {

                Section {

                    ScrollView(.horizontal, showsIndicators: false) {

                        HStack(spacing: 10) {

                            ForEach(eventManager.currentWeek, id: \.self){ day in

                                VStack(spacing: 10){

                                    Text(eventManager.extractDate(date: day, format: "dd"))
                                        .font(.system(size: 15))
                                        .fontWeight(.semibold)

                                    Text(eventManager.extractDate(date: day, format: "EEE"))
                                        .font(.system(size: 14))

                                    Circle()
                                        .fill(.white)
                                        .frame(width: 8, height: 8)
                                        .opacity(eventManager.isToday(date: day) ? 1 : 0)

                                }
                                .foregroundStyle(eventManager.isToday(date: day) ? .primary : .secondary)
                                .foregroundColor(eventManager.isToday(date: day) ? .white : .black)
                                .frame(width: 45, height: 90)
                                .background(
                                    ZStack {
                                        if eventManager.isToday(date: day) {
                                            Capsule()
                                                .fill(Color("Purple1"))
                                                .matchedGeometryEffect(id: "CURRENTDAY", in: animation)
                                        }
                                    }
                                )
                                .contentShape(Capsule())
                                .onTapGesture {
                                    withAnimation {
                                        eventManager.currentDay = day
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    EventView()

                } header: {

                    HeaderView()
                }
            }

        }
        .ignoresSafeArea(.container, edges: .top)
        .overlay (

            Button(action: {
                eventManager.addNewEvent.toggle()
                eventManager.isRefreshing.toggle()
                self.isEditing = false
                self.selectedEventId = UUID()
            }, label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Purple1"), in: Circle())
            })
            .padding()
            .padding(.trailing, 10)
            ,alignment: .bottomTrailing
        )
        .sheet(isPresented: $eventManager.addNewEvent) {
            
            BBCalendarAppRev1.EventView(isEditing: $isEditing, selectedEventId: $selectedEventId)
                .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)

        }
        .onAppear {
            
            SQLiteDatabase.shared.creatTable()
            
            withAnimation {
                DispatchQueue.main.async {
                    eventManager.allEvents = SQLiteCommands.getEvents()
                    eventManager.filterTodayEvents()
                }
            }
    
        }

    }
    
    func HeaderView() -> some View {
        
        HStack(spacing: 10) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(Date().formatted(date: .abbreviated, time: .omitted))
                    .foregroundColor(.secondary)
                
                Text("Today")
                    .font(.system(size: 35, weight: .bold))
                    .foregroundColor(.primary)
            }
            .hLeading()
            
            Button  {
                SQLiteCommands.deleteAllData()
                DispatchQueue.main.async {
                    eventManager.allEvents = SQLiteCommands.getEvents()
                    eventManager.filterTodayEvents()
                }
            } label: {
                Text("DELETE")
            }

            
            Button {
                
            } label: {
                
                Image("Backham")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 45, height: 45)
                    .clipShape(Circle())
            }

        }
        .padding()
        .padding(.horizontal, 5)
        .padding(.top, getSafeArea().top)
        .background(Color.white)
        
    }
    
    func EventView() -> some View {
        
//        LazyVStack(spacing: 20) {
        
        VStack(spacing: 20) {
            
            if $eventManager.filteredEvents.isEmpty {
                
                Text("No Events found.")
                    .font(.system(size: 16))
                    .fontWeight(.light)
                    .offset(y: 100)

            } else {
        
                ForEach($eventManager.filteredEvents) { $event in

                    EventCardView(event: $event)
                        .onLongPressGesture(minimumDuration: 0.2) {
                            self.selectedEventId = event.id
//
                            self.isEditing = true
//                            print(selectedEventId)
                            
//                            self.selectedEvent = event

                            let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
                            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
                            
                            impactRigid.impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                impactHeavy.impactOccurred()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    self.hasSelected.toggle()
                                }
                            }
                        }


                }
                .sheet(isPresented: $hasSelected) {
                    
                    BBCalendarAppRev1.EventView(isEditing: $isEditing, selectedEventId: $selectedEventId)
                        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                        .onDisappear {
                            DispatchQueue.main.async {
                                eventManager.filteredEvents.removeAll()
                                eventManager.allEvents = SQLiteCommands.getEvents()
                                eventManager.filterTodayEvents()
                            }
                        }

                }
            }

//            if let events = eventManager.filteredEvents {
//
//                if events.isEmpty {
//
//                    Text("No Events found.")
//                        .font(.system(size: 16))
//                        .fontWeight(.light)
//                        .offset(y: 100)
//
//                } else {
//
//                    ForEach(events) { event in
//                        EventCardView(event: event)
//                            .onLongPressGesture {
//                                self.selectedEventId = event.id
//                                self.hasSelected.toggle()
//                                print(selectedEventId)
//                            }
//
//                    }
//                    .sheet(isPresented: $hasSelected) {
//                        EditEventView(id: $selectedEventId)
//                            .onDisappear {
//                                DispatchQueue.main.async{
//
//                                    eventManager.filteredEvents.removeAll()
//                                    eventManager.allEvents = SQLiteCommands.getEvents()
//                                    eventManager.filterTodayEvents()
//                                }
//                            }
//                    }
//
//                }
//
//            } else {
//                ProgressView()
//                    .offset(y: 100)
//            }
        }
        .padding()
        .padding(.horizontal, 10)
        .padding(.top)
        .onChange(of: eventManager.currentDay) { newValue in

            DispatchQueue.main.async {
                eventManager.allEvents = SQLiteCommands.getEvents()
                eventManager.filterTodayEvents()
            }

        }
    }
    
    func deleteItems(offsets: IndexSet) {
        
        withAnimation {
            guard let index = offsets.first else { return }
            let event = eventManager.filteredEvents[index]
            SQLiteCommands.deleteEvent(idValue: event.id)
            eventManager.filteredEvents.remove(at: index)
            
        }

    }
    
//    func EventCardView(event: Event) -> some View {
//
//        HStack(alignment: .top, spacing: 30) {
//
//            VStack(spacing: 10) {
//
//                Circle()
//                    .fill(eventManager.isCurrentHour(date: event.eventDateFrom) ? .black : .clear)
//                    .frame(width: 15, height: 15)
//                    .background(Circle().stroke(Color("Purple1"), lineWidth: 2).padding(-3))
//                    .scaleEffect(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0.8)
//
//                Rectangle()
//                    .fill(.black)
//                    .frame(width: 3)
//            }
//
//            VStack {
//
//                HStack(alignment: .top, spacing: 10) {
//
//                    VStack(alignment: .leading, spacing: 12) {
//
//                        Text(event.eventTitle)
//                            .font(.system(size: 20, weight: .bold))
//
//                        Text(event.eventDescription)
//                            .font(.system(size: 14))
//                            .foregroundStyle(.secondary)
//                    }
//                    .hLeading()
//
//                    VStack {
////                        Text(event.eventDateFrom.formatted(date: .omitted, time: .shortened))
//                        Text(DateManager.shared.dateToStringGetTime(date: event.eventDateFrom))
//                            .font(.system(size: 16, weight: .medium))
//                            .padding(.bottom, 1)
//
//                        Text("|")
//                            .font(.system(size: 15, weight: .medium))
//                            .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)
//
////                        Text(event.eventDateTo.formatted(date: .omitted, time: .shortened))
//                        Text(DateManager.shared.dateToStringGetTime(date: event.eventDateTo))
//                            .font(.system(size: 16, weight: .medium))
//                            .padding(.top, 1)
//                            .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)
//                    }
//                    .padding(5)
//
//                }
//
//            }
//            .foregroundColor(eventManager.isCurrentHour(date: event.eventDateFrom) ? .white : .gray)
//            .padding(.top, eventManager.isCurrentHour(date: event.eventDateFrom) ? 20 : -5)
//            .padding(.bottom, eventManager.isCurrentHour(date: event.eventDateFrom) ? 20 : -15)
//            .padding(.horizontal, 20)
//            .hLeading()
//            .background(
//                eventManager.getColor(colorCode: event.eventColorCode).cornerRadius(25)
//                    .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)
////                Color("Purple1").cornerRadius(25)
//            )
//            .overlay(RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 3).foregroundColor(Color.white).padding(3).opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0))
//
//            .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 4).foregroundColor(Color("Purple1")).opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0))
//        }
//        .hLeading()
//
//
//    }
}

struct EventCardView: View {

    @EnvironmentObject private var eventManager: EventManager

    @Binding var event: Event

    @GestureState var gestureOffset: CGFloat = 0

    @State var offset: CGFloat = 0
    @State var lastStoredOffset: CGFloat = 0
    @State var showDeleteOption: Bool = false

    @State var isRe = false

    var body: some View {

        HStack(alignment: .top, spacing: 30) {

            VStack(spacing: 10) {

                Circle()
                    .fill(eventManager.isCurrentHour(date: event.eventDateFrom) ? Color(event.eventColorCode) : .clear)
                    .frame(width: 15, height: 15)
                    .background(Circle().stroke(Color("Purple1"), lineWidth: 2).padding(-3))
                    .scaleEffect(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0.8)

                Rectangle()
                    .fill(.black)
                    .frame(width: 3)
            }

            VStack {

                HStack(alignment: .top, spacing: 10) {

                    VStack(alignment: .leading, spacing: 12) {

                        Text(event.eventTitle)
                            .font(.system(size: 20, weight: .bold))

                        Text(event.eventDescription)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                    .hLeading()

                    VStack {
    //                        Text(event.eventDateFrom.formatted(date: .omitted, time: .shortened))
                        Text(DateManager.shared.dateToStringGetTime(date: event.eventDateFrom))
                            .font(.system(size: 16, weight: .medium))
                            .padding(.bottom, 1)

                        Text("|")
                            .font(.system(size: 15, weight: .medium))
                            .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)

    //                        Text(event.eventDateTo.formatted(date: .omitted, time: .shortened))
                        Text(DateManager.shared.dateToStringGetTime(date: event.eventDateTo))
                            .font(.system(size: 16, weight: .medium))
                            .padding(.top, 1)
                            .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)
                    }
                    .padding(5)

                }

            }
            .foregroundColor(eventManager.isCurrentHour(date: event.eventDateFrom) ? .white : .gray)
            .padding(.top, eventManager.isCurrentHour(date: event.eventDateFrom) ? 20 : -5)
            .padding(.bottom, eventManager.isCurrentHour(date: event.eventDateFrom) ? 20 : -15)
            .padding(.horizontal, 20)
            .hLeading()
            .background(
                Color(event.eventColorCode).cornerRadius(25)
                    .opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0)
                
            )
            .overlay(RoundedRectangle(cornerRadius: 22).stroke(lineWidth: 3).foregroundColor(Color.white).padding(3).opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0))

            .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 4).foregroundColor(Color("Purple1")).opacity(eventManager.isCurrentHour(date: event.eventDateFrom) ? 1 : 0))
        }
        .padding(5)
        .background(Color.white.cornerRadius(eventManager.isCurrentHour(date: event.eventDateFrom) ? 25 : 10))
        .hLeading()
        .offset(x: offset)
        .background {

            ZStack(alignment: .trailing){

                Color.red

                VStack(alignment: .center){

                    Button {
                        
                        SQLiteCommands.deleteEvent(idValue: event.id)
                        
                        if let index = eventManager.filteredEvents.firstIndex(where: { $0.id == event.id}) {
                            eventManager.filteredEvents.remove(at: index)
                        }

                    } label: {
                        Image(systemName: "trash.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 16, height: 16)
                    }
                }
                .foregroundColor(.white)
                .padding(.horizontal, 27)
            }
            .cornerRadius(eventManager.isCurrentHour(date: event.eventDateFrom) ? 26 : 11)

        }
        .gesture(

            DragGesture()
                .updating($gestureOffset, body: { value, out, _ in

                    out = value.translation.width

                }).onEnded({ value in

                    let translation = value.translation.width

                    if translation < 0 && -translation > 70 && -translation < UIScreen.main.bounds.width / 2 {
                        offset = -70
                    }else if translation < 0 && -translation > UIScreen.main.bounds.width / 2 {
                        offset = -800
                        SQLiteCommands.deleteEvent(idValue: event.id)
                        if let index = eventManager.filteredEvents.firstIndex(where: { $0.id == event.id}) {
                            eventManager.filteredEvents.remove(at: index)
                        }

                    }else{
                        offset = 0
                    }

                    lastStoredOffset = offset
                })
        )
        .animation(.easeInOut, value: gestureOffset == 0)
        .onChange(of: gestureOffset) { newValue in
            offset = (gestureOffset + lastStoredOffset) > 0 ? 0 : (gestureOffset + lastStoredOffset)
        }

        .onAppear {
            DispatchQueue.main.async {
                eventManager.allEvents = SQLiteCommands.getEvents()
                eventManager.filterTodayEvents()
            }
        }
    }

    func deleteItem(indexSet: IndexSet) {
        eventManager.filteredEvents.remove(atOffsets: indexSet)
    }

}


extension View {
    
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func hTrailing() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    func hCenter() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func getSafeArea() -> UIEdgeInsets {
        
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        guard let safeArea = screen.windows.first?.safeAreaInsets else {
            return .zero
        }
        
        return safeArea
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

