//
//  HistoryView.swift
//  HLS
//
//  Created by Антон Мальцев on 30.11.2025.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var storageManager: StorageManager
    @State private var showingDeleteAlert = false
    @State private var entryToDelete: DailyEntry?

    var body: some View {
        NavigationView {
            Group {
                if storageManager.entries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("Нет сохранённых записей")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(storageManager.entries) { entry in
                            NavigationLink(destination: ContentView(editingEntry: entry)
                                .environmentObject(storageManager)) {
                                EntryRow(entry: entry)
                            }
                        }
                        .onDelete { indexSet in
                            if let index = indexSet.first {
                                entryToDelete = storageManager.entries[index]
                                showingDeleteAlert = true
                            }
                        }
                    }
                }
            }
            .navigationTitle("История записей")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }

                if !storageManager.entries.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
            .alert("Удалить запись?", isPresented: $showingDeleteAlert) {
                Button("Отмена", role: .cancel) {
                    entryToDelete = nil
                }
                Button("Удалить", role: .destructive) {
                    if let entry = entryToDelete {
                        storageManager.deleteEntry(entry)
                        entryToDelete = nil
                    }
                }
            } message: {
                Text("Эта запись будет удалена без возможности восстановления")
            }
        }
    }
}

struct EntryRow: View {
    let entry: DailyEntry

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Дата
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text(dateFormatter.string(from: entry.date))
                    .font(.headline)
            }

            // Грехи
            if entry.badFood || entry.alcohol || entry.smoking {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Грехи:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if entry.badFood {
                        HStack {
                            Text("🍔")
                                .foregroundColor(.red)
                            Text("Вредная еда")
                            if !entry.badFoodComment.isEmpty {
                                Text("(\(entry.badFoodComment))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)
                    }

                    if entry.alcohol {
                        HStack {
                            Text("🍷")
                                .foregroundColor(.red)
                            Text("Алкоголь")
                            if !entry.alcoholComment.isEmpty {
                                Text("(\(entry.alcoholComment))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)
                    }

                    if entry.smoking {
                        HStack {
                            Text("🚬")
                                .foregroundColor(.red)
                            Text("Курение")
                            if !entry.smokingComment.isEmpty {
                                Text("(\(entry.smokingComment))")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.caption)
                    }
                }
            }

            // Послушание
            VStack(alignment: .leading, spacing: 4) {
                Text("Послушание:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("🚶‍♂️")
                        .foregroundColor(.green)
                    Text("\(entry.steps) шагов")
                }
                .font(.caption)

                if entry.sport, let sportType = entry.sportType {
                    HStack {
                        Text("🏋️")
                            .foregroundColor(.green)
                        Text(sportType)
                        if !entry.sportComment.isEmpty {
                            Text("(\(entry.sportComment))")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
}
