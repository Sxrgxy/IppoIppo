//
//  HabitNameSheet.swift
//  IppoIppo
//
//  Created by dev on 12.11.2026.
//

import SwiftUI

// Вью лист, которое всплывает при зажатии на площади привычки
struct HabitNameSheet: View {
    
    let header: LocalizedStringKey
    
    let initialName: String
    
    let onSave: (String) -> Void
    
    @State private var inputText: String = ""
    
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isKeyboardFocused: Bool
    
    var body: some View {
        
        // для панели с заголовками
        NavigationStack {
            Form {
                TextField("🧘 Habit name", text: $inputText)
                    .focused($isKeyboardFocused)
                    .onSubmit { save() }
            }
            .navigationTitle(header)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(inputText.trimmed.isEmpty) // кнопка неактивна, пока текст привычки не введен
                }
            }
            .onAppear {
                isKeyboardFocused = true
                inputText = initialName
            }
            .navigationBarTitleDisplayMode(.inline) // маленький заголовк, не крупный, как ставится по умолчанию
        }
        
    }
    
    private func save() {
        guard !inputText.trimmed.isEmpty else { return }
        // если введенный текст не пуст, то сохраняем и скрываем окно
        onSave(inputText.trimmed)
        dismiss()
    }
    
}
