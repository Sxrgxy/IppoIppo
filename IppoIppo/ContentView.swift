//
//  ContentView.swift
//  IppoIppo
//
//  Created by dev on 25.10.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    // для первой привычки при первой загрузке приложения
    @AppStorage("createInitialHabit") private var createInitialHabit = true
    
    // 1. Fetch the context from the environment
    @Environment(\.modelContext) private var modelContext
    
    @Environment(\.scenePhase) private var scenePhase //
    
    @State private var today = dateToUTC(date: Date()) // обновлять текущую дату
    
    // Fetching data automatically using @Query and sorting them by order col value
    @Query(sort: \Habit.order) private var habits: [Habit]
    
    @State private var habitToDelete: Habit?

    @State private var isShowingDeleteAlert = false
    
    @State private var isShowingAddSheet = false
    
    @State private var habitToRename: Habit?
    
    var body: some View {
        NavigationStack {
            Group {
                if habits.isEmpty {
                    ContentUnavailableView(
                        "Create your first habit",
                        systemImage: "square.grid.3x3", description: Text("Tap + at the top to add a habit.")
                    )
                } else {
                    // чтение сохраненных привычек из бд
                    // видимо через цикл по колонке отображаю
                    List() {
                        ForEach(habits) { habit in
                            VStack(spacing: 4) {
                                HStack {
                                    // название привычки
                                    Text(habit.name)
                                    Spacer()
                                    // икони добавить/отменить
                                    Button(action: {
                                        // функция проверки и добавления/удаления даты в лог
                                        habit.toggleLog(date: dateToUTC(date:Date()), modelContext: modelContext)
                                    }) {
                                        Image(systemName: habit.logs.contains {log in log.date == today} ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 22))
                                            .frame(width: 33, height: 33)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.borderless) // хз зачем?
                                }
                                // сетка с днями
                                HabitGridView(habit: habit, today: today)
                            }
                            .contextMenu { // по зажатию переименовать
                                Button("Rename") {
                                    habitToRename = habit // копируем объект текущей привычки habit
                                }
                                Button("Delete", role: .destructive) {
                                    habitToDelete = habit
                                    isShowingDeleteAlert = true
                                }
                            }
                            // вибрация при нажатии
                            .sensoryFeedback(.selection, trigger: habit.logs.count)
                        }
                    }
                    .scrollDismissesKeyboard(.interactively) // скрыть клавиатуру
                }
            }
            .onAppear { if createInitialHabit == true { createInitialHabit = false;  modelContext.insert(Habit(name: String(localized: "My first habit"), order: 0)) } }
            // Приложение стало активным (например, вернулось из фона): обновляем today, ведь пока оно было свёрнуто, день мог смениться
            .onChange(of: scenePhase) { if scenePhase == .active { today = dateToUTC(date: Date()) }}
            // Система сообщила о смене календарного дня, пока приложение запущено (например, открыто в полночь): обновляем today. Это @State, поэтому экран перерисуется, и обводка с сеткой перейдут на новый день
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in today = dateToUTC(date: Date()) }
            .alert("Delete this habit?", isPresented: $isShowingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let habitToDelete {
                        modelContext.delete(habitToDelete)
                    }
                    habitToDelete = nil
                }
                Button("Cancel", role: .cancel) {}
            }
            message: { Text("Its entire history will be deleted too.") }
            
            .navigationTitle("Habits") // задаёт заголовок экрана в навигационной панели, которую даёт NavigationStack. Без стека заголовку негде показаться.
            // добавляет кнопки в эту же панель. Без placement элемент встаёт в стандартное место, справа вверху.
            .toolbar {
                ToolbarItem {
                    Button("Add", systemImage: "plus") {
                        isShowingAddSheet = true
                    }
                }
            }
            // показывает лист, которые выезжает снизу, если $isShowingAddSheet становится true
            .sheet(isPresented: $isShowingAddSheet) {
                HabitNameSheet(header: "New Habit", initialName: "", onSave: { name in
                    // получаем макс значение order
                    let maxOrder = habits.map(\.order).max() ?? -1
                    // сохранить в бд
                    let newHabit = Habit(name: name, order: maxOrder + 1)
                    // добавляем новую привычку
                    modelContext.insert(newHabit)
                })
                .presentationDetents([.medium])
            }
            // когда в habitToRename кладут привычку, открывается лист переименования; при закрытии SwiftUI снова ставит nil
            .sheet(item: $habitToRename) { habit in
                HabitNameSheet(header: "Rename", initialName: habit.name, onSave: {  name in habit.name = name })
                    .presentationDetents([.medium])
            }
        }
    }
}

#Preview {
    ContentView()
}
