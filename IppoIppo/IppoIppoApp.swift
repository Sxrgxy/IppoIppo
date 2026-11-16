//
//  IppoIppoApp.swift
//  IppoIppo
//
//  Created by dev on 25.10.2026.
//

import SwiftUI
import SwiftData

@main
struct IppoIppoApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Schema(SchemaV1.models), migrationPlan: HabitMigrationPlan.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container) // передаем созданный persistent data storage на iphone
    }
}
