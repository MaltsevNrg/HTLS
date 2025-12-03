//
//  HistoryEmbedded.swift
//  HTLS
//
//  Embedded history JSON so import works even if the file isn't in the bundle
//

import Foundation

let embeddedHistoryJSON = """
{
  "schema_version": 1,
  "source": "embedded_fallback",
  "generated_at": "2025-12-03T00:00:00Z",
  "days": [],
  "trainings": []
}
"""

func decodeEmbeddedHistory() -> [DailyEntry]? {
    let decoder = JSONDecoder()
    guard let data = embeddedHistoryJSON.data(using: .utf8) else { return nil }
    do {
        let root = try decoder.decode(HistoryImportRoot.self, from: data)
        let convertedEntries = root.days.compactMap { day in
            day.toDailyEntry(trainings: root.trainings)
        }
        return convertedEntries
    } catch {
        print("HistoryEmbedded: failed to decode - \(error)")
        return nil
    }
}
