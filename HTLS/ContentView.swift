//
//  ContentView.swift
//  HLS
//
//  Created by Антон Мальцев on 27.11.2025.
//

import SwiftUI

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
    @State private var weight: Double = 90.0
    @State private var badFood = false
    @State private var alcohol = false
    @State private var smoking = false

    @State private var badFoodComment = ""
    @State private var alcoholComment = ""
    @State private var smokingComment = ""

    @State private var sport = false
    @State private var selectedSport: SportType = .pullUps
    @State private var sportComment = ""
    @State private var trainingExercises: [ExercisePerformance] = []

    @StateObject private var healthStore = HealthStore()
    @EnvironmentObject var storageManager: StorageManager

    @State private var showingHistorySheet = false

    var body: some View {
        NavigationView {
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
                            .onChange(of: weight) { _ in autoSave() }
                        HStack(spacing: 16) {
                            Button(action: {
                                weight = Double(round(10 * max(70.0, (weight - 0.1))) / 10)
                                autoSave()
                            }) {
                                Text("−0.1")
                            }
                            .buttonStyle(.borderedProminent)
                            Button(action: {
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
                    .onChange(of: badFood) { _ in autoSave() }
                    if badFood {
                        HStack {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            TextField("Комментарий...", text: $badFoodComment)
                                .onChange(of: badFoodComment) { _ in autoSave() }
                        }
                    }

                    Toggle(isOn: $alcohol) {
                        HStack {
                            Text("🍷")
                            Text("Алкоголь")
                        }
                    }
                    .onChange(of: alcohol) { _ in autoSave() }
                    if alcohol {
                        HStack {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            TextField("Комментарий...", text: $alcoholComment)
                                .onChange(of: alcoholComment) { _ in autoSave() }
                        }
                    }

                    Toggle(isOn: $smoking) {
                        HStack {
                            Text("🚬")
                            Text("Курение")
                        }
                    }
                    .onChange(of: smoking) { _ in autoSave() }
                    if smoking {
                        HStack {
                            Text("🗒️")
                                .foregroundColor(.secondary)
                            TextField("Комментарий...", text: $smokingComment)
                                .onChange(of: smokingComment) { _ in autoSave() }
                        }
                    }
                }

                Section(header: Text("Послушание")) {
                    HStack {
                        Text("🚶‍♂️")
                        Text("Шаги за сегодня")
                        Spacer()
                        if healthStore.isLoading {
                            ProgressView()
                        } else {
                            Text("\(healthStore.stepsToday)")
                                .bold()
                        }
                    }
                    .contextMenu {
                        Button(action: {
                            healthStore.refreshSteps()
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
                    .onChange(of: sport) { _ in autoSave() }
                    if sport {
                        Picker(
                            selection: $selectedSport,
                            label: Text("Тип тренировки")
                        ) {
                            Text("Подтягивания").tag(SportType.pullUps)
                            Text("Отжимания").tag(SportType.pushUps)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedSport) { _ in
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
                                    Text("Отдых: \(ex.restSeconds) сек")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(ex.metric == .reps ? "Повторы" : "Секунды")
                                        .font(.caption2)
                                        .padding(4)
                                        .background(Color.gray.opacity(0.15))
                                        .cornerRadius(6)
                                }
                                ForEach(0..<ex.sets, id: \.self) { setIndex in
                                    HStack(spacing: 16) {
                                        Text("Подход \(setIndex + 1)")
                                            .frame(width: 80, alignment: .leading)
                                        Button(action: {
                                            if trainingExercises[idx].values[setIndex] > 0 {
                                                trainingExercises[idx].values[setIndex] -= (ex.metric == .reps ? 1 : 5)
                                                autoSave()
                                            }
                                        }) {
                                            Image(systemName: "minus")
                                                .frame(width: 44, height: 44)
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
                                            trainingExercises[idx].values[setIndex] += (ex.metric == .reps ? 1 : 5)
                                            autoSave()
                                        }) {
                                            Image(systemName: "plus")
                                                .frame(width: 44, height: 44)
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                }
                            }
                            .padding(.vertical, 6)
                        }
                        TextField("Комментарий к тренировке...", text: $sportComment)
                            .onChange(of: sportComment) { _ in autoSave() }
                    }
                }

            }
            .navigationTitle(todayTitle())
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
                loadTodayEntry()
            }
        }
    }

    private func autoSave() {
        let entry = DailyEntry(
            date: Date(),
            badFood: badFood,
            badFoodComment: badFoodComment,
            alcohol: alcohol,
            alcoholComment: alcoholComment,
            smoking: smoking,
            smokingComment: smokingComment,
            steps: healthStore.stepsToday,
            weight: weight,
            sport: sport,
            sportType: sport ? selectedSport.rawValue : nil,
            sportComment: sportComment,
            trainingExercises: sport ? trainingExercises : nil
        )
        storageManager.saveEntry(entry)
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
                ExercisePerformance(
                    name: "От пола медленно", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 10),
                ExercisePerformance(name: "Ноги на стуле", metric: .reps, sets: 2, restSeconds: 90, defaultValue: 14),
                ExercisePerformance(name: "Максимум", metric: .reps, sets: 1, restSeconds: 0, defaultValue: 20),
            ]
        case .pullUps:
            trainingExercises = [
                ExercisePerformance(name: "Вис", metric: .seconds, sets: 2, restSeconds: 90, defaultValue: 20),
                ExercisePerformance(name: "С опорой", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(name: "Негативы", metric: .reps, sets: 2, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(name: "Внутренний хват", metric: .reps, sets: 1, restSeconds: 120, defaultValue: 2),
                ExercisePerformance(
                    name: "Вис на максимум", metric: .seconds, sets: 1, restSeconds: 0, defaultValue: 30),
            ]
        }
    }
}

#Preview {
    ContentView()
}
