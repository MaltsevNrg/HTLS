//
//  HistoryEmbedded.swift
//  HLS
//
//  Embedded history JSON so import works even if the file isn't in the bundle
//

import Foundation

let embeddedHistoryJSON = """
[
  {
    "alcohol" : true,
    "alcoholComment" : "2 пива, 2 вина",
    "badFood" : true,
    "badFoodComment" : "Красная меля с белым",
    "date" : "2025-10-14T21:00:00Z",
    "id" : "E2DAA24B-8583-4722-AEBD-936FC2E09A1A",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : false,
    "sportComment" : "",
    "steps" : 0,
    "weight" : 92.2
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-13T21:00:00Z",
    "id" : "F56828DF-1451-421F-A34F-FDDB66663E9C",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : true,
    "sportComment" : "",
    "sportType" : "Подтягивания",
    "steps" : 10103,
    "trainingExercises" : [
      {
        "id" : "DC16A5D4-01E6-42CC-B77C-E7720F4AA53E",
        "metric" : "reps",
        "name" : "С опорой",
        "restSeconds" : 120,
        "sets" : 1,
        "values" : [
          2
        ]
      }
    ],
    "weight" : 92.6
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : true,
    "badFoodComment" : "Пико и лор = 92.5",
    "date" : "2025-10-15T21:00:00Z",
    "id" : "0652A7CD-942D-42E2-B479-1A5706C2BC61",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : true,
    "sportComment" : "",
    "sportType" : "Отжимания",
    "steps" : 0
  },
  {
    "alcohol" : true,
    "alcoholComment" : "Красное вино",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-15T21:00:00Z",
    "id" : "9F69DE27-E7FE-4892-97D8-67B6EA2F02BB",
    "smoking" : true,
    "smokingComment" : "Блюм, с мясом",
    "sport" : false,
    "sportComment" : "",
    "steps" : 0,
    "weight" : 92.2
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-16T21:00:00Z",
    "id" : "41823EFC-2F48-4ADA-A32B-CDEE45C1C465",
    "smoking" : true,
    "smokingComment" : "Блюм, с мясом",
    "sport" : false,
    "sportComment" : "",
    "steps" : 3950,
    "weight" : 93.5
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-17T21:00:00Z",
    "id" : "5AB350FA-27A6-4041-A3AA-5837A64295E8",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : false,
    "sportComment" : "",
    "steps" : 400,
    "weight" : 92.6
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-18T21:00:00Z",
    "id" : "E29B9C74-AD1F-410B-BE4C-E2D1CD285773",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : false,
    "sportComment" : "",
    "steps" : 1000,
    "weight" : 92.7
  },
  {
    "alcohol" : true,
    "alcoholComment" : "Красное вино",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-19T21:00:00Z",
    "id" : "658B8D6A-87B3-432F-838B-4044E9A3D5AE",
    "smoking" : true,
    "smokingComment" : "Дело, нельзя",
    "sport" : false,
    "sportComment" : "",
    "steps" : 4900,
    "weight" : 92.5
  },
  {
    "alcohol" : true,
    "alcoholComment" : "Пиво",
    "badFood" : true,
    "badFoodComment" : "Чарли джем",
    "date" : "2025-10-20T21:00:00Z",
    "id" : "0B9D9A6B-F6DB-437D-A78B-B8A1281BAB5A",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : true,
    "sportComment" : "",
    "sportType" : "Отжимания+жжение",
    "steps" : 3000,
    "weight" : 91.6
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-21T21:00:00Z",
    "id" : "D94FD3FB-0251-4B7A-8AFA-B263B7C249D1",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : true,
    "sportComment" : "",
    "sportType" : "Отжимания",
    "steps" : 3100,
    "trainingExercises" : [
      {
        "id" : "63577277-C328-4D73-B8E1-F69922984611",
        "metric" : "reps",
        "name" : "От пола медленно",
        "restSeconds" : 120,
        "sets" : 2,
        "values" : [
          10,
          10
        ]
      }
    ],
    "weight" : 91.2
  },
  {
    "alcohol" : false,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-22T21:00:00Z",
    "id" : "727A4DEA-F2E6-4C9E-9F65-CD684E2335DC",
    "smoking" : true,
    "smokingComment" : "У Питера с трам",
    "sport" : false,
    "sportComment" : "",
    "steps" : 4900,
    "weight" : 92.6
  },
  {
    "alcohol" : true,
    "alcoholComment" : "Дело, нельзя",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-23T21:00:00Z",
    "id" : "706DF8B9-902C-4FDD-AAF6-ED46211488B5",
    "smoking" : true,
    "smokingComment" : "Блюм, с мясом",
    "sport" : true,
    "sportComment" : "",
    "sportType" : "Отжимания",
    "steps" : 12090121201290,
    "trainingExercises" : [
      {
        "id" : "4D6E2D3A-F6F9-4AC3-922C-04A2F0284DEF",
        "metric" : "reps",
        "name" : "От пола медленно",
        "restSeconds" : 120,
        "sets" : 2,
        "values" : [
          10,
          10
        ]
      }
    ],
    "weight" : 92.2
  },
  {
    "alcohol" : true,
    "alcoholComment" : "",
    "badFood" : false,
    "badFoodComment" : "",
    "date" : "2025-10-24T21:00:00Z",
    "id" : "C1D72E34-5B0C-4C66-B1A6-3F2F8D9F4D45",
    "smoking" : false,
    "smokingComment" : "",
    "sport" : false,
    "sportComment" : "",
    "steps" : 0
  }
]
"""

func decodeEmbeddedHistory() -> [DailyEntry]? {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return try? decoder.decode([DailyEntry].self, from: Data(embeddedHistoryJSON.utf8))
}
