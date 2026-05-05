//
//  pomodoroApp.swift
//  pomodoro
//
//  Created by vanessa pellegrini on 05-05-26.
//

import SwiftUI
import CoreData

@main
struct pomodoroApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
