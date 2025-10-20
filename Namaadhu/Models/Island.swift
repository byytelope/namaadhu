import Foundation
import GRDB

struct Island: FetchableRecord, Identifiable, Codable, Equatable, Hashable {
  let id: Int
  let categoryId: Int
  let atoll: Atoll
  let island: String
  let minutes: Int
  let latitude: Double
  let longitude: Double
  let status: Int

  var name: String {
    "\(atoll.rawValue) \(island)"
  }

  private enum CodingKeys: String, CodingKey {
    case id, atoll, island, minutes, latitude, longitude, status
    case categoryId = "category_id"
  }
}

struct IslandCategory: FetchableRecord, Identifiable, Decodable {
  let id: Int
}

enum Atoll: String, CaseIterable, Codable, Hashable, Identifiable,
  DatabaseValueConvertible
{
  case haaAlifu = "HA."
  case haaDhaalu = "HDh."
  case shaviyani = "Sh."
  case noonu = "N."
  case raa = "R."
  case baa = "B."
  case lhaviyani = "Lh."
  case kaafu = "K."
  case alifuAlifu = "AA."
  case alifuDhaalu = "ADh."
  case vaavu = "V."
  case meemu = "M."
  case faafu = "F."
  case dhaalu = "Dh."
  case thaa = "Th."
  case laamu = "L."
  case gaafuAlifu = "GA."
  case gaafuDhaalu = "GDh."
  case gnaviyani = "Gn."
  case seenu = "S."

  var id: String { rawValue }

  var fullName: String {
    switch self {
    case .haaAlifu: return "Haa Alifu"
    case .haaDhaalu: return "Haa Dhaalu"
    case .shaviyani: return "Shaviyani"
    case .noonu: return "Noonu"
    case .raa: return "Raa"
    case .baa: return "Baa"
    case .lhaviyani: return "Lhaviyani"
    case .kaafu: return "Kaafu"
    case .alifuAlifu: return "Alifu Alifu"
    case .alifuDhaalu: return "Alifu Dhaalu"
    case .vaavu: return "Vaavu"
    case .meemu: return "Meemu"
    case .faafu: return "Faafu"
    case .dhaalu: return "Dhaalu"
    case .thaa: return "Thaa"
    case .laamu: return "Laamu"
    case .gaafuAlifu: return "Gaafu Alifu"
    case .gaafuDhaalu: return "Gaafu Dhaalu"
    case .gnaviyani: return "Gnaviyani"
    case .seenu: return "Seenu"
    }
  }

  var displayOrder: Int {
    switch self {
    case .haaAlifu: return 1
    case .haaDhaalu: return 2
    case .shaviyani: return 3
    case .noonu: return 4
    case .raa: return 5
    case .baa: return 6
    case .lhaviyani: return 7
    case .kaafu: return 8
    case .alifuAlifu: return 9
    case .alifuDhaalu: return 10
    case .vaavu: return 11
    case .meemu: return 12
    case .faafu: return 13
    case .dhaalu: return 14
    case .thaa: return 15
    case .laamu: return 16
    case .gaafuAlifu: return 17
    case .gaafuDhaalu: return 18
    case .gnaviyani: return 19
    case .seenu: return 20
    }
  }
}
