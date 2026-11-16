//
//  CalendarDates.swift
//  IppoIppo
//
//  Created by dev on 31.10.2026.
//

import Foundation

// расширение для удаления пробелов и новых строк в слове
extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

var utcCalendar: Calendar {
    var utcCalendar = Calendar(identifier: .gregorian)
    utcCalendar.timeZone = .gmt
    utcCalendar.firstWeekday = Calendar.current.firstWeekday // начало недели как в настройках системы
    utcCalendar.locale = .current
    return utcCalendar
}

func calculateGridDates(today: Date) -> [[Date]] {
    
    // берём календарь один раз, чтобы не создавать его заново в каждой итерации цикла
    let calendar = utcCalendar
    
    // определяем неделю для входящей даты
    guard let interval = calendar.dateInterval(of: .weekOfYear, for: today) else { return [] }
    // начало недели для недели (Пнд)
    let startOfWeek = interval.start
    // от понедельнка текущей недели отсупили ровно 51 неделю назад
    guard let pastDate = calendar.date(byAdding: .weekOfYear, value: -51, to: startOfWeek) else { return [] }
    
    // переменная для хранения 52 недель по дням в формате [[date,date,date,date...], [....],...]
    var weeksList: [[Date]] = []
    // луп генерации дат
    for week in 0..<52 {
        
        var daysOfWeek = [Date]()
        
        for day in 0..<7 {
            guard let dayOfWeek = calendar.date(byAdding: .day, value: week*7+day, to: pastDate) else { continue }
            daysOfWeek.append(dayOfWeek)
        }
        weeksList.append(daysOfWeek)
    }
    return weeksList
}

// принимает дату и сохраняет ее (местный календарный день) как полночь UTC
func dateToUTC(date: Date) -> Date {
    var localCalendar = Calendar(identifier: .gregorian)
    localCalendar.timeZone = .current
    
    // выделили год, месяц и дату из переданной даты
    let components = localCalendar.dateComponents([.year, .month, .day], from: date)
    
    return utcCalendar.date(from: components)! // конвертируем переданную дату в GMT формат
}

// вычисляю день недели из дня и беру соответствующий символ этого дня недели для подписи оси
func weekdayLabel(date: Date) -> String {
    let calendar = utcCalendar
    return calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
}

// ищу в неделе первое число месяца; если нашёл, возвращаю короткое название этого месяца для подписи над колонкой,
// иначе пустую строку
func monthLabel(week: [Date]) -> String {
    let calendar = utcCalendar
    
    if let firstDayOfMonth = week.first(where: {day in calendar.component(.day, from: day) == 1} ) {
        return calendar.shortStandaloneMonthSymbols[calendar.component(.month, from: firstDayOfMonth) - 1]
    } else { return "" }
}
