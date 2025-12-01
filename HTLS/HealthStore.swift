import Foundation
import HealthKit
import Combine

enum HealthKitError: Error, LocalizedError {
    case notAvailable
    case authorizationDenied
    case dataUnavailable

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKit недоступен на этом устройстве"
        case .authorizationDenied:
            return "Доступ к HealthKit запрещён. Разрешите доступ в настройках."
        case .dataUnavailable:
            return "Не удалось получить данные из HealthKit"
        }
    }
}

enum AuthorizationStatus {
    case notDetermined
    case authorized
    case denied
    case unavailable
}

@MainActor
final class HealthStore: ObservableObject {
    private let healthStore = HKHealthStore()

    @Published var stepsToday: Int = 0
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    var isHealthKitAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    init() {
        checkAvailability()
    }

    private func checkAvailability() {
        guard isHealthKitAvailable else {
            authorizationStatus = .unavailable
            errorMessage = HealthKitError.notAvailable.errorDescription
            return
        }
        requestAuthorization()
    }

    func requestAuthorization() {
        guard isHealthKitAvailable else {
            authorizationStatus = .unavailable
            return
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Не удалось получить тип данных для шагов"
            return
        }

        isLoading = true

        healthStore.requestAuthorization(toShare: [], read: [stepType]) { [weak self] success, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Ошибка авторизации: \(error.localizedDescription)"
                    self.authorizationStatus = .denied
                    return
                }

                if success {
                    self.authorizationStatus = .authorized
                    self.errorMessage = nil
                    self.fetchTodaySteps()
                } else {
                    self.authorizationStatus = .denied
                    self.errorMessage = HealthKitError.authorizationDenied.errorDescription
                }
            }
        }
    }

    func fetchTodaySteps() {
        guard authorizationStatus == .authorized else {
            return
        }

        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            errorMessage = "Не удалось получить тип данных для шагов"
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { [weak self] _, result, error in
            Task { @MainActor [weak self] in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Ошибка получения данных: \(error.localizedDescription)"
                    return
                }

                var steps = 0
                if let sum = result?.sumQuantity() {
                    steps = Int(sum.doubleValue(for: HKUnit.count()))
                }

                self.stepsToday = steps
                self.errorMessage = nil
            }
        }

        healthStore.execute(query)
    }

    func refreshSteps() {
        fetchTodaySteps()
    }
}
