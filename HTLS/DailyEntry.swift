//
//  DailyEntry.swift
//  HLS
//
//  Created by Антон Мальцев on 30.11.2025.
//

import Foundation

struct DailyEntry: Identifiable, Codable {
    let id: UUID
    let date: Date

    // Грехи
    var badFood: Bool
    var badFoodComment: String

    var alcohol: Bool
    var alcoholComment: String

    var smoking: Bool
    var smokingComment: String

    // Послушание
    var steps: Int
    var weight: Double?

    var sport: Bool
    var sportType: String?
    var sportComment: String
    var trainingExercises: [ExercisePerformance]?  // План с настройками подходов

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        badFood: Bool = false,
        badFoodComment: String = "",
        alcohol: Bool = false,
        alcoholComment: String = "",
        smoking: Bool = false,
        smokingComment: String = "",
        steps: Int = 0,
        weight: Double? = nil,
        sport: Bool = false,
        sportType: String? = nil,
        sportComment: String = "",
        trainingExercises: [ExercisePerformance]? = nil
    ) {
        self.id = id
        self.date = date
        self.badFood = badFood
        self.badFoodComment = badFoodComment
        self.alcohol = alcohol
        self.alcoholComment = alcoholComment
        self.smoking = smoking
        self.smokingComment = smokingComment
        self.steps = steps
        self.weight = weight
        self.sport = sport
        self.sportType = sportType
        self.sportComment = sportComment
        self.trainingExercises = trainingExercises
    }
}
