//
//  ContentView.swift
//  HLS
//
//  Created by Антон Мальцев on 27.11.2025.
//

import SwiftUI
import UIKit

enum SportType: String, CaseIterable, Identifiable {
    case pullUps = "Подтягивания"
    case pushUps = "Отжимания"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .pullUps: return "figure.pullup"
        case .pushUps: return "figure.pushup"
        }
        }

    
    }

    struct ContentView: View {
    let editingEntry: DailyEntry?

    @State private var weight: Double
    @State private var badFood = false
    @State private var alcohol = false
    @State private var smoking = false

    @State private var steps: Int = 0
    @State private var previewStepsString: String = ""

    @State private var badFoodComment = ""
    @State private var alcoholComment = ""
    @State private var smokingComment = ""

    @State private var sport = false
    @State private var selectedSport: SportType = .pullUps
    @State private var sportComment = ""
    @State private var trainingExercises: [ExercisePerformance] = []

    // If editing an existing history entry, keep its id/date to preserve identity
    private var editingID: UUID?
    private var editingDate: Date?

    @StateObject private var healthStore = HealthStore()
    @EnvironmentObject var storageManager: StorageManager

    @State private var showingHistorySheet = false
    @State private var scrollHapticTriggered = false
    // MARK: - Init
    init(editingEntry: DailyEntry? = nil) {
        self.editingEntry = editingEntry
        // initialize states from editingEntry or defaults
        _weight = State(initialValue: editingEntry?.weight ?? 90.0)
        _badFood = State(initialValue: editingEntry?.badFood ?? false)
        _alcohol = State(initialValue: editingEntry?.alcohol ?? false)
        _smoking = State(initialValue: editingEntry?.smoking ?? false)
        _badFoodComment = State(initialValue: editingEntry?.badFoodComment ?? "")
        _alcoholComment = State(initialValue: editingEntry?.alcoholComment ?? "")
        _smokingComment = State(initialValue: editingEntry?.smokingComment ?? "")
        _sport = State(initialValue: editingEntry?.sport ?? false)
        if let sportTypeRaw = editingEntry?.sportType, let st = SportType.allCases.first(where: { $0.rawValue == sportTypeRaw }) {
            _selectedSport = State(initialValue: st)
        } else {
            _selectedSport = State(initialValue: .pullUps)
        }
        _sportComment = State(initialValue: editingEntry?.sportComment ?? "")
          _trainingExercises = State(initialValue: editingEntry?.trainingExercises ?? [])
          _steps = State(initialValue: editingEntry?.steps ?? 0)
          if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
              _previewStepsString = State(initialValue: "3300")
          }
        self.editingID = editingEntry?.id
        self.editingDate = editingEntry?.date
    }

    var body: some View {
        Form {
                // Ввод веса
                Section(header: Text("Вес")) {
                    VStack(spacing: 12) {
                        HStack {
                            Text("⚖️ Вес")
                            Spacer()
                            Text(String(format: "%.1f кг", weight))
                                .monospacedDigit()
                                .bold()
                        }
                        Slider(value: $weight, in: 70...100, step: 0.1)
                            .tint(.blue)
                            .accessibilityLabel("Вес")
                            .accessibilityValue(String(format: "%.1f килограмм", weight))
                              .onChange(of: weight) { autoSave() }
                        HStack(spacing: 16) {
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                weight = Double(round(10 * max(70.0, (weight - 0.1))) / 10)
                                autoSave()
                            }) {
                                Text("−0.1")
                            }
                            .buttonStyle(.borderedProminent)
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                weight = Double(round(10 * min(100.0, (weight + 0.1))) / 10)
                                autoSave()
                            }) {
                                Text("+0.1")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                // Статус HealthKit
                if healthStore.authorizationStatus == .unavailable {
                    Section {
                        Label("HealthKit недоступен на этом устройстве", systemImage: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                    }
                } else if healthStore.authorizationStatus == .denied {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Доступ к HealthKit запрещён", systemImage: "hand.raised.fill")
                                .foregroundColor(.red)
                            Text("Разрешите доступ в Настройках → Конфиденциальность → Здоровье")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Ошибки HealthKit
                if let errorMessage = healthStore.errorMessage {
                    Section {
                        Label(errorMessage, systemImage: "exclamationmark.circle")
                            .foregroundColor(.red)
                    }
                }

                Section(header: Text("Грехи")) {
                    Toggle(isOn: $badFood) {
                        HStack {
                            Text("🍔")
                            Text("Вредная еда")
                        }
                    }
                      .onChange(of: badFood) { autoSave() }
                    if badFood {
                        HStack(alignment: .top) {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            ZStack(alignment: .topLeading) {
                                if badFoodComment.isEmpty {
                                    Text("Комментарий...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $badFoodComment)
                                    .frame(minHeight: 60)
                                      .onChange(of: badFoodComment) { autoSave() }
                            }
                        }
                    }

                    Toggle(isOn: $alcohol) {
                        HStack {
                            Text("🍷")
                            Text("Алкоголь")
                        }
                    }
                      .onChange(of: alcohol) { autoSave() }
                    if alcohol {
                        HStack(alignment: .top) {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            ZStack(alignment: .topLeading) {
                                if alcoholComment.isEmpty {
                                    Text("Комментарий...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $alcoholComment)
                                    .frame(minHeight: 60)
                                      .onChange(of: alcoholComment) { autoSave() }
                            }
                        }
                    }

                    Toggle(isOn: $smoking) {
                        HStack {
                            Text("🚬")
                            Text("Курение")
                        }
                    }
                      .onChange(of: smoking) { autoSave() }
                    if smoking {
                        HStack(alignment: .top) {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            ZStack(alignment: .topLeading) {
                                if smokingComment.isEmpty {
                                    Text("Комментарий...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                                TextEditor(text: $smokingComment)
                                    .frame(minHeight: 60)
                                      .onChange(of: smokingComment) { autoSave() }
                            }
                        }
                    }
                }

                Section(header: Text("Активность")) {
                    HStack {
                        Text("🚶‍♂️")
                        Text("Шаги")
                        Spacer()
                        stepsView
                    }
                            .contextMenu {
                                Button(action: {
                                    if Calendar.current.isDateInToday(editingDate ?? Date()) {
                                        healthStore.refreshSteps()
                                    }
                                }) {
                                    HStack {
                                        Text("🔄")
                                        Text("Обновить")
                                    }
                                }
                            }

                    Toggle(isOn: $sport) {
                        HStack {
                            Text("🏋️")
                            Text("Спорт")
                        }
                    }
                    .onChange(of: sport) { autoSave() }
                    if sport {
                        Picker(
                            selection: $selectedSport,
                            label: Text("Тип тренировки")
                        ) {
                            Text("Подтягивания").tag(SportType.pullUps)
                            Text("Отжимания").tag(SportType.pushUps)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedSport) {
                            generatePlan()
                            autoSave()
                        }
                        .onAppear { if trainingExercises.isEmpty { generatePlan() } }
                    }
                }

                if sport {
                    Section(header: Text("План")) {
                        ForEach(trainingExercises.indices, id: \.self) { idx in
                            let ex = trainingExercises[idx]
                            VStack(alignment: .leading, spacing: 8) {
                                Text(ex.name)
                                    .font(.headline)
                                HStack(spacing: 12) {
                                    Text("Отдых: \(ex.restSeconds) секунд")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                ForEach(0..<ex.sets, id: \.self) { setIndex in
                                    HStack {
                                        Text("Подход \(setIndex + 1)")
                                            .frame(width: 80, alignment: .leading)
                                        Spacer()
                                        HStack(spacing: 16) {
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                if trainingExercises[idx].values[setIndex] > 0 {
                                                    trainingExercises[idx].values[setIndex] -= (ex.metric == .reps ? 1 : 5)
                                                    autoSave()
                                                }
                                            }) {
                                                Text("−")
                                            }
                                            .buttonStyle(.borderedProminent)
                                            Text(
                                                ex.metric == .reps
                                                    ? "\(trainingExercises[idx].values[setIndex]) раз"
                                                    : "\(trainingExercises[idx].values[setIndex]) сек"
                                            )
                                            .monospacedDigit()
                                            .frame(minWidth: 60)
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                trainingExercises[idx].values[setIndex] += (ex.metric == .reps ? 1 : 5)
                                                autoSave()
                                            }) {
                                                Text("+")
                                            }
                                            .buttonStyle(.borderedProminent)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        TextField("Комментарий к тренировке...", text: $sportComment)
                            .onChange(of: sportComment) { autoSave() }
                    }
                    .simultaneousGesture(DragGesture(minimumDistance: 10)
                        .onChanged { _ in
                            if !scrollHapticTriggered {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                scrollHapticTriggered = true
                            }
                        }
                        .onEnded { _ in
                            scrollHapticTriggered = false
                        }
                    )
                }

            }
            .navigationTitle(editingEntry != nil ? editingTitle() : todayTitle())
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingHistorySheet = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .sheet(isPresented: $showingHistorySheet) {
                HistoryView()
            }
            .onAppear {
                if editingEntry == nil { loadTodayEntry() }
            }
        }

    private func autoSave() {
        let entry = DailyEntry(
            id: editingID ?? UUID(),
            date: editingDate ?? Date(),
            badFood: badFood,
            badFoodComment: badFoodComment,
            alcohol: alcohol,
            alcoholComment: alcoholComment,
            smoking: smoking,
            smokingComment: smokingComment,
              steps: Calendar.current.isDateInToday(editingDate ?? Date()) ? healthStore.stepsToday : steps,
            weight: weight,
            sport: sport,
            sportType: sport ? selectedSport.rawValue : nil,
            sportComment: sportComment,
            trainingExercises: sport ? trainingExercises : nil
        )
        storageManager.saveEntry(entry)
    }

    private func editingTitle() -> String {
        guard let d = editingDate else { return "Запись" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        return formatter.string(from: d)
    }

    private func todayTitle() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "EEEE, d MMMM"
        let dateStr = formatter.string(from: Date())
        return "Сегодня: " + dateStr
    }

    private func loadTodayEntry() {
        if let todayEntry = storageManager.getTodayEntry() {
            badFood = todayEntry.badFood
            badFoodComment = todayEntry.badFoodComment
            alcohol = todayEntry.alcohol
            alcoholComment = todayEntry.alcoholComment
            smoking = todayEntry.smoking
            smokingComment = todayEntry.smokingComment
            sport = todayEntry.sport
            if let w = todayEntry.weight {
                weight = w
            }
              steps = todayEntry.steps
            if let sportType = todayEntry.sportType,
                let type = SportType.allCases.first(where: { $0.rawValue == sportType })
            {
                selectedSport = type
            }
            sportComment = todayEntry.sportComment
            if let loaded = todayEntry.trainingExercises { trainingExercises = loaded }
        }
    }

    private func generatePlan() {
        switch selectedSport {
        case .pushUps:
            trainingExercises = [
                ExercisePerformance(name: "От пола", metric: .reps, sets: 3, restSeconds: 90, defaultValue: 20),
                ExercisePerformance(name: "От пола медленно", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 10),
                ExercisePerformance(name: "Ноги на стуле", metric: .reps, sets: 2, restSeconds: 90, defaultValue: 14),
                ExercisePerformance(name: "Максимум", metric: .reps, sets: 1, restSeconds: 120, defaultValue: 20),
            ]
        case .pullUps:
            trainingExercises = [
                ExercisePerformance(name: "Вис", metric: .seconds, sets: 2, restSeconds: 90, defaultValue: 20),
                ExercisePerformance(name: "С опорой", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(name: "Негативы", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(name: "Внутренний хват", metric: .reps, sets: 1, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(name: "Вис на максимум", metric: .seconds, sets: 1, restSeconds: 120, defaultValue: 30),
            ]
        }
    }

    private var stepsView: some View {
        let isToday = Calendar.current.isDateInToday(editingDate ?? Date())
        return Group {
            if isToday {
                // In previews when HealthKit is unavailable show an editable field with cursor
                if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" && healthStore.authorizationStatus != .authorized {
                    HStack {
                        TextField("", text: $previewStepsString)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(.body, design: .monospaced)).bold()
                            .frame(minWidth: 60)
                        Text("шагов")
                            .foregroundColor(.secondary)
                    }
                } else {
                    if healthStore.isLoading {
                        ProgressView()
                    } else {
                        Text("\(healthStore.stepsToday)")
                            .bold()
                    }
                }
            } else {
                HStack {
                    Text("\(steps)")
                        .bold()
                    Spacer()
                    Stepper("", value: $steps, in: 0...30000, step: 100)
                        .labelsHidden()
                        .onChange(of: steps) { autoSave() }
                }
            }
        }
    }

}

#Preview {
    ContentView()
        .environmentObject(StorageManager())
}
