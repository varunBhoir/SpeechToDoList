//
//  SpeechToDoListApp.swift
//  SpeechToDoList
//
//  Created by varun bhoir on 19/03/21.
//

import SwiftUI

@main
struct SpeechToDoListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
