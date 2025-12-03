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
    private let importFlagKey = "historyImportDone_v1"

    init() {
        loadEntries()
        importHistoryOnce()
    }

    /// One-time import from bundled `history_import.json` (new schema with days/trainings).
    private func importHistoryOnce() {
        // Skip if already imported
        if UserDefaults.standard.bool(forKey: importFlagKey) { return }

        // Only import when we don't already have entries to avoid duplicates
        if !entries.isEmpty {
            UserDefaults.standard.set(true, forKey: importFlagKey)
            return
        }

        let decoder = JSONDecoder()

        // Try to load from bundle first, otherwise fall back to embedded JSON
        var imported: [DailyEntry]? = nil

        if let fileURL = Bundle.main.url(forResource: "history_import", withExtension: "json") ?? Bundle.main.resourceURL?.appendingPathComponent("history_import.json") {
            do {
                let data = try Data(contentsOf: fileURL)
                let root = try decoder.decode(HistoryImportRoot.self, from: data)
                
                // Convert days to DailyEntry objects
                let convertedEntries = root.days.compactMap { day in
                    day.toDailyEntry(trainings: root.trainings)
                }
                
                imported = convertedEntries
                print("StorageManager: imported \(imported?.count ?? 0) entries from bundled history_import.json (schema v\(root.schemaVersion))")
            } catch {
                print("StorageManager: failed to decode bundled history_import.json - \(error). Will try embedded JSON.")
            }
        }

        if imported == nil {
            if let decoded = decodeEmbeddedHistory() {
                imported = decoded
                print("StorageManager: imported \(decoded.count) entries from embedded JSON")
            } else {
                print("StorageManager: no history_import.json in bundle and embedded JSON failed to decode")
            }
        }

        guard let entriesToImport = imported, !entriesToImport.isEmpty else { return }

        // Merge without duplicating by date (since imported entries have new UUIDs)
        for e in entriesToImport {
            if !entries.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: e.date) }) {
                entries.append(e)
            }
        }
        entries.sort { $0.date > $1.date }
        saveEntries()
        UserDefaults.standard.set(true, forKey: importFlagKey)
    }

    func saveEntry(_ entry: DailyEntry) {
        if let indexByID = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[indexByID] = entry
        } else if let indexByDate = entries.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: entry.date) }) {
            entries[indexByDate] = entry
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
