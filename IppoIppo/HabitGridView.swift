//
//  HabitGridView.swift
//  IppoIppo
//
//  Created by dev on 31.10.2026.
//

import SwiftUI
import SwiftData


// Вью сетки с точками привычек (grid) и с логикой их формирования и закрашивания
struct HabitGridView: View {
    
    // Fetch the context from the environment
    @Environment(\.modelContext) private var modelContext
    
    var habit: Habit
    
    var today: Date
    
    var weeksList : [[Date]] { calculateGridDates(today: today) } // значение не хранится, а пересчитывается при каждом обращении
    
    // цвета клеток grid по дням
    private func gridColor(day: Date) -> Color {
        
        if day > today { return Color.gray.opacity(0.08) }
        
        if habit.logs.contains(where: {log in log.date == day}) { return Color.accentColor } else { return Color.gray.opacity(0.2) }
        
    }
    
    // цвета клетки сегодняшнего дня
    private func todayColor(day: Date) -> Color {
        if day == today { return Color.accentColor } else {
            return .clear
        }
    }
    
    var body: some View {
        
        let weeks = weeksList // чтобы сетка из 365 дат считалась один раз за перерисовку, а не четыре
        
        HStack {
            // горизонтальная прокрутка
            ScrollView(.horizontal) {
                // колонки недели. итерируемся
                HStack(spacing: 3) {
                    ForEach(weeks, id: \.self) { week in
                        // дни недели - строки
                        VStack(spacing: 3) {
                            // легенда месяцев
                            Text(monthLabel(week: week))
                                .fixedSize()
                                .frame(width: 12, height: 12, alignment: .leading)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            ForEach(week, id: \.self) { day in
                                
                                //
                                let isLogged =  habit.logs.contains(where: {log in log.date == day})
                                
                                RoundedRectangle(cornerRadius: 3)
                                // закрашиваем день если у привычки в логах есть совпадение по дате с датой итерирования
                                    .fill(gridColor(day: day))
                                    .animation(.snappy, value: isLogged) // анимация закрашивания клетки
                                    .sensoryFeedback(.impact(weight: .light), trigger: isLogged, condition: { _, _ in day != today }) // вибрация
                                    .frame(width: 12, height: 12)
                                    .keyframeAnimator(initialValue: 1.0, trigger: isLogged) { content, scale in
                                        content.scaleEffect(scale)
                                    } keyframes: { _ in
                                        CubicKeyframe(1.2, duration: 0.2)
                                        SpringKeyframe(1.0, duration: 0.4)
                                    } // анимация клетки
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(todayColor(day: day), lineWidth: 1) //
                                            .padding(-2)
                                    )
                                // при тапе на RoundedRectangle. Для будуших дней не работает
                                    .onTapGesture() { if day <= today { habit.toggleLog(date: day, modelContext: modelContext) } }
                            }
                        }
                    }
                }
                .padding(.trailing, 3)
                .padding(.vertical, 3)
            }
            .defaultScrollAnchor(.trailing)
            
            VStack(spacing: 3) {
                
                // пустота для сдвига на один ряд вниз, чтобы дни недели совпали
                Color.clear
                    .frame(width: 12, height: 12, alignment: .leading)
                
                ForEach(0..<7, id: \.self) { row in
                    Group {if [1, 3, 5].contains(row), let firstWeek = weeks.first {
                        Text(weekdayLabel(date: firstWeek[row]))
                    } else { Text(verbatim: "") }
                    }
                    .frame(height: 12)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}
