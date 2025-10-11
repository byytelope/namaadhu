import Foundation
import GRDB

struct Island: FetchableRecord, Identifiable, Codable, Equatable {
  let id: Int
  let categoryId: Int
  let atoll: String
  let island: String
  let minutes: Int
  let latitude: Double
  let longitude: Double
  let status: Int

  var name: String {
    "\(atoll) \(island)"
  }

  private enum CodingKeys: String, CodingKey {
    case id, atoll, island, minutes, latitude, longitude, status
    case categoryId = "category_id"
  }
}

struct IslandCategory: FetchableRecord, Identifiable, Decodable {
  let id: Int
}
