//
//  Models.swift
//  IppoIppo
//
//  Created by dev on 25.10.2026.
//

import SwiftData
import Foundation

enum SchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitLog.self]
    }
    
    @Model
    class Habit {
        var name: String
        
        // связь одной строки Habit со всеми его HabitLogs
        @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
        var logs: [HabitLog] = []
        
        // для визуальной сортировки привычек
        var order: Int = 0
        
        init(name: String, order: Int) {
            self.name = name
            self.order = order
        }
    }


    @Model
    class HabitLog {
        var date: Date
        var habit: Habit
        
        // like a unique constraint
        #Unique<HabitLog>([\.date, \.habit])
        
        init(date: Date, habit: Habit) {
            self.date = date
            self.habit = habit
        }
    }
}

typealias Habit = SchemaV1.Habit
typealias HabitLog = SchemaV1.HabitLog


extension Habit {
    
    func toggleLog(date: Date, modelContext: ModelContext) {
        // проверить дату
        // если нашли в логах привычки переданную дату - удаляем
        if let dateLog = self.logs.first(where: { log in log.date == date })
            
        // найденную дату удаляем
        { modelContext.delete(dateLog)
        // иначе - создаем
        } else {
            let newLog = HabitLog(date: date, habit: self)
            modelContext.insert(newLog)
            try? modelContext.save() // сразу обновляем modelContext
        }
    }
}

enum HabitMigrationPlan: SchemaMigrationPlan {
    // список версий
    static var schemas: [any VersionedSchema.Type] {
        [SchemaV1.self]
    }
    
    // этапы миграций
    static var stages: [MigrationStage] {
        []
    }
}
