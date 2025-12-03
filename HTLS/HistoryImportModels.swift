//
//  HistoryImportModels.swift
//  HTLS
//
//  Created by Антон Мальцев on 03.12.2025.
//

import Foundation

// MARK: - Root structure for history_import.json

struct HistoryImportRoot: Codable {
    let schemaVersion: Int
    let source: String
    let generatedAt: String
    let days: [ImportedDay]
    let trainings: [ImportedTraining]
    
    enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case source
        case generatedAt = "generated_at"
        case days
        case trainings
    }
}

struct ImportedDay: Codable {
    let date: String  // "2025-10-13"
    let weightKg: Double?
    let weightRaw: String?
    let junkFood: String?
    let alcohol: String?
    let hookah: String?
    let aerobicSteps: Int?
    let trainingType: String?
    let trainingId: String?
    
    enum CodingKeys: String, CodingKey {
        case date
        case weightKg = "weight_kg"
        case weightRaw = "weight_raw"
        case junkFood = "junk_food"
        case alcohol
        case hookah
        case aerobicSteps = "aerobic_steps"
        case trainingType = "training_type"
        case trainingId = "training_id"
    }
}

struct ImportedTraining: Codable {
    let id: String
    let date: String
    let type: String
    let exercises: [ImportedExercise]
}

struct ImportedExercise: Codable {
    let raw: String
    let name: String?
    let values: [Int]
    let sets: Int?
    let restSec: Int?
    let unit: String  // "reps" or "sec"
    
    enum CodingKeys: String, CodingKey {
        case raw
        case name
        case values
        case sets
        case restSec = "rest_sec"
        case unit
    }
}

// MARK: - Conversion to DailyEntry

extension ImportedDay {
    func toDailyEntry(trainings: [ImportedTraining]) -> DailyEntry? {
        // Parse date string "2025-10-13"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        guard let entryDate = formatter.date(from: date) else { return nil }
        
        // Find matching training
        let training = trainingId != nil ? trainings.first(where: { $0.id == trainingId }) : nil
        
        // Convert exercises
        let exercises: [ExercisePerformance]? = training?.exercises.compactMap { ex in
            guard let sets = ex.sets, sets > 0 else { return nil }
            let metric: ExerciseMetric = (ex.unit == "sec") ? .seconds : .reps
            let name = ex.name ?? ex.raw
            
            var perf = ExercisePerformance(
                id: UUID(),
                name: name,
                metric: metric,
                sets: sets,
                restSeconds: ex.restSec ?? 0,
                defaultValue: 0
            )
            
            // Fill values array from imported values
            perf.values = ex.values.isEmpty ? Array(repeating: 0, count: sets) : ex.values
            // Ensure values array has correct length
            if perf.values.count < sets {
                perf.values += Array(repeating: 0, count: sets - perf.values.count)
            } else if perf.values.count > sets {
                perf.values = Array(perf.values.prefix(sets))
            }
            
            return perf
        }
        
        return DailyEntry(
            id: UUID(),
            date: entryDate,
            badFood: junkFood != nil,
            badFoodComment: junkFood ?? "",
            alcohol: alcohol != nil,
            alcoholComment: alcohol ?? "",
            smoking: hookah != nil,
            smokingComment: hookah ?? "",
            steps: aerobicSteps ?? 0,
            weight: weightKg,
            sport: training != nil,
            sportType: training?.type,
            sportComment: "",
            trainingExercises: exercises
        )
    }
}
