//
//  TrainingModels.swift
//  HLS
//
//  Created by Антон Мальцев on 30.11.2025.
//

import Foundation

enum ExerciseMetric: String, Codable {
    case reps
    case seconds
}

struct ExercisePerformance: Identifiable, Codable {
    let id: UUID
    let name: String
    let metric: ExerciseMetric
    let sets: Int
    let restSeconds: Int
    // Значения для каждого подхода (повторы или секунды)
    var values: [Int]

    init(id: UUID = UUID(), name: String, metric: ExerciseMetric, sets: Int, restSeconds: Int, defaultValue: Int) {
        self.id = id
        self.name = name
        self.metric = metric
        self.sets = sets
        self.restSeconds = restSeconds
        self.values = Array(repeating: defaultValue, count: sets)
    }
}
