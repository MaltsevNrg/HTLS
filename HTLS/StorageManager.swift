//
//  StorageManager.swift
//  HLS
//
//  Created by Антон Мальцев on 30.11.2025.
//

import Foundation
import Combine

final class StorageManager: ObservableObject {
    @Published var entries: [DailyEntry] = []

    private let entriesKey = "dailyEntries"

    init() {
        loadEntries()
    }

    func saveEntry(_ entry: DailyEntry) {
        if let index = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        entries.sort { $0.date > $1.date }
        saveEntries()
    }

    func getTodayEntry() -> DailyEntry? {
        let today = Date()
        return entries.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    func deleteEntry(_ entry: DailyEntry) {
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }

    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
            let decoded = try? JSONDecoder().decode([DailyEntry].self, from: data)
        {
            entries = decoded
        }
    }
}
